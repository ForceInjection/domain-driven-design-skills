---
name: rust-s3-patterns
description: Implement S3 operations with rust-s3 including streaming downloads, multipart uploads, and batch operations. Use for cloud storage integration.
---

# S3 Storage Patterns

Cloud storage operations with rust-s3 crate.

## Setup

```toml
# Cargo.toml
[dependencies]
rust-s3 = { version = "0.33", default-features = false, features = ["tokio-native-tls"] }
bytes = "1"
```

## Storage Client

```rust
use s3::bucket::Bucket;
use s3::creds::Credentials;
use s3::region::Region;
use bytes::Bytes;

#[derive(Clone)]
pub struct StorageClient {
    bucket: Box<Bucket>,
    base_path: String,
}

impl StorageClient {
    pub async fn new(
        bucket_name: &str,
        region: &str,
        endpoint: Option<&str>,
        base_path: &str,
    ) -> Result<Self> {
        // Load credentials from environment
        let credentials = Credentials::from_env()
            .map_err(|e| Error::S3(format!("Failed to load credentials: {}", e)))?;

        // Build region (custom for S3-compatible services)
        let s3_region = if let Some(endpoint_url) = endpoint {
            Region::Custom {
                region: region.to_string(),
                endpoint: endpoint_url.to_string(),
            }
        } else {
            region.parse()
                .unwrap_or_else(|_| Region::Custom {
                    region: region.to_string(),
                    endpoint: format!("https://s3.{}.amazonaws.com", region),
                })
        };

        let bucket = Bucket::new(bucket_name, s3_region, credentials)?
            .with_path_style();  // Required for MinIO and some S3-compatible services

        Ok(Self {
            bucket,
            base_path: base_path.to_string(),
        })
    }

    fn full_key(&self, key: &str) -> String {
        if self.base_path.is_empty() {
            key.to_string()
        } else {
            format!("{}/{}", self.base_path, key)
        }
    }
}
```

## Upload Operations

```rust
impl StorageClient {
    /// Upload bytes to S3
    pub async fn upload_file(
        &self,
        key: &str,
        data: Bytes,
        content_type: Option<&str>,
    ) -> Result<String> {
        let full_key = self.full_key(key);
        let ct = content_type.unwrap_or("application/octet-stream");

        self.bucket
            .put_object_with_content_type(&full_key, &data, ct)
            .await
            .map_err(|e| Error::S3(format!("Upload failed: {}", e)))?;

        Ok(format!("s3://{}/{}", self.bucket.name(), full_key))
    }

    /// Upload from local file
    pub async fn upload_local_file(
        &self,
        local_path: &Path,
        s3_key: &str,
        content_type: Option<&str>,
    ) -> Result<String> {
        let data = tokio::fs::read(local_path).await?;
        self.upload_file(s3_key, Bytes::from(data), content_type).await
    }

    /// Upload with automatic content type detection
    pub async fn upload_auto(
        &self,
        local_path: &Path,
        s3_key: &str,
    ) -> Result<String> {
        let content_type = mime_guess::from_path(local_path)
            .first_raw()
            .unwrap_or("application/octet-stream");

        self.upload_local_file(local_path, s3_key, Some(content_type)).await
    }
}
```

## Download Operations

```rust
impl StorageClient {
    /// Download to bytes
    pub async fn download_file(&self, key: &str) -> Result<Bytes> {
        let full_key = self.full_key(key);

        let response = self.bucket
            .get_object(&full_key)
            .await
            .map_err(|e| Error::S3(format!("Download failed: {}", e)))?;

        Ok(Bytes::from(response.to_vec()))
    }

    /// Download to local file
    pub async fn download_to_file(
        &self,
        key: &str,
        local_path: &Path,
    ) -> Result<()> {
        let data = self.download_file(key).await?;

        // Ensure parent directory exists
        if let Some(parent) = local_path.parent() {
            tokio::fs::create_dir_all(parent).await?;
        }

        tokio::fs::write(local_path, &data).await?;
        Ok(())
    }

    /// Streaming download for large files
    pub async fn download_streaming(
        &self,
        key: &str,
        writer: &mut (impl tokio::io::AsyncWrite + Unpin),
    ) -> Result<u64> {
        let full_key = self.full_key(key);

        let response = self.bucket
            .get_object_stream(&full_key)
            .await
            .map_err(|e| Error::S3(format!("Stream download failed: {}", e)))?;

        let bytes_written = tokio::io::copy(&mut response.bytes.as_ref(), writer).await?;
        Ok(bytes_written)
    }
}
```

## Existence and Metadata

```rust
impl StorageClient {
    /// Check if object exists
    pub async fn file_exists(&self, key: &str) -> Result<bool> {
        let full_key = self.full_key(key);

        match self.bucket.head_object(&full_key).await {
            Ok(_) => Ok(true),
            Err(e) => {
                let err_str = e.to_string();
                if err_str.contains("404") || err_str.contains("NotFound") {
                    Ok(false)
                } else {
                    Err(Error::S3(format!("Head object failed: {}", e)))
                }
            }
        }
    }

    /// Get object metadata
    pub async fn get_metadata(&self, key: &str) -> Result<ObjectMetadata> {
        let full_key = self.full_key(key);

        let (head, _) = self.bucket
            .head_object(&full_key)
            .await
            .map_err(|e| Error::S3(format!("Head object failed: {}", e)))?;

        Ok(ObjectMetadata {
            size: head.content_length.unwrap_or(0) as u64,
            content_type: head.content_type,
            last_modified: head.last_modified,
        })
    }
}
```

## Deletion

```rust
impl StorageClient {
    /// Delete single object
    pub async fn delete_file(&self, key: &str) -> Result<()> {
        let full_key = self.full_key(key);

        self.bucket
            .delete_object(&full_key)
            .await
            .map_err(|e| Error::S3(format!("Delete failed: {}", e)))?;

        Ok(())
    }

    /// Delete multiple objects
    pub async fn delete_many(&self, keys: &[String]) -> Result<usize> {
        let mut deleted = 0;

        for key in keys {
            if self.delete_file(key).await.is_ok() {
                deleted += 1;
            }
        }

        Ok(deleted)
    }
}
```

## Presigned URLs

```rust
impl StorageClient {
    /// Generate presigned download URL
    pub async fn presigned_get_url(
        &self,
        key: &str,
        expiration_secs: u64,
    ) -> Result<String> {
        let full_key = self.full_key(key);

        let url = self.bucket
            .presign_get(&full_key, expiration_secs as u32, None)
            .await
            .map_err(|e| Error::S3(format!("Presign failed: {}", e)))?;

        Ok(url)
    }

    /// Generate presigned upload URL
    pub async fn presigned_put_url(
        &self,
        key: &str,
        expiration_secs: u64,
    ) -> Result<String> {
        let full_key = self.full_key(key);

        let url = self.bucket
            .presign_put(&full_key, expiration_secs as u32, None)
            .await
            .map_err(|e| Error::S3(format!("Presign failed: {}", e)))?;

        Ok(url)
    }
}
```

## Batch Operations with Semaphore

```rust
use std::sync::Arc;
use tokio::sync::Semaphore;
use futures::stream::{self, StreamExt};

impl StorageClient {
    /// Download multiple files concurrently
    pub async fn download_batch(
        &self,
        keys: &[String],
        local_dir: &Path,
        max_concurrent: usize,
    ) -> Result<Vec<PathBuf>> {
        let semaphore = Arc::new(Semaphore::new(max_concurrent));

        let results: Vec<_> = stream::iter(keys)
            .map(|key| {
                let sem = semaphore.clone();
                let client = self.clone();
                let local_path = local_dir.join(key);
                let key = key.clone();

                async move {
                    let _permit = sem.acquire().await?;
                    client.download_to_file(&key, &local_path).await?;
                    Ok::<PathBuf, Error>(local_path)
                }
            })
            .buffer_unordered(max_concurrent * 2)
            .collect()
            .await;

        results.into_iter().collect()
    }

    /// Upload directory to S3
    pub async fn upload_directory(
        &self,
        local_dir: &Path,
        s3_prefix: &str,
        max_concurrent: usize,
    ) -> Result<usize> {
        let semaphore = Arc::new(Semaphore::new(max_concurrent));

        let mut files = Vec::new();
        let mut entries = tokio::fs::read_dir(local_dir).await?;

        while let Some(entry) = entries.next_entry().await? {
            if entry.file_type().await?.is_file() {
                files.push(entry.path());
            }
        }

        let results: Vec<_> = stream::iter(files)
            .map(|path| {
                let sem = semaphore.clone();
                let client = self.clone();
                let file_name = path.file_name().unwrap().to_string_lossy().to_string();
                let s3_key = format!("{}/{}", s3_prefix, file_name);

                async move {
                    let _permit = sem.acquire().await?;
                    client.upload_local_file(&path, &s3_key, None).await
                }
            })
            .buffer_unordered(max_concurrent * 2)
            .collect()
            .await;

        let uploaded = results.iter().filter(|r| r.is_ok()).count();
        Ok(uploaded)
    }
}
```

## Guidelines

- Use `with_path_style()` for S3-compatible services (MinIO, etc.)
- Load credentials from environment variables
- Use semaphores for concurrent batch operations
- Handle 404 errors gracefully in existence checks
- Use presigned URLs for temporary access
- Stream large files instead of loading into memory
- Set appropriate content types for files

## Examples

See `hercules-local-algo/src/storage/mod.rs` for complete implementation.
