---
name: unit-test-generator
description: Generate pytest unit tests for Python functions and classes with fixtures, parametrization, and edge cases. This skill should be used when creating test coverage for modules, especially during refactoring to ensure functionality is preserved.
---

# Unit Test Generator

Generate comprehensive pytest unit tests for Python code with proper fixtures, parametrization, and edge case coverage.

## Purpose

Automate creation of unit tests following pytest best practices. Essential for maintaining code quality during refactoring and ensuring functions behave as expected.

## When to Use

Use this skill when:
- Adding tests for newly refactored modules (30+ test files needed)
- Creating test coverage for existing untested code
- Need parametrized tests for multiple input scenarios
- Testing PyTorch models and tensor operations
- Establishing baseline test suite before refactoring

## Test Structure Pattern

```python
# tests/unit/test_telescope.py
"""Unit tests for telescope module."""

import pytest
import torch
from torch import Tensor

from prism.core.telescope import Telescope


class TestTelescope:
    """Test suite for Telescope class."""

    @pytest.fixture
    def telescope(self) -> Telescope:
        """Create a standard telescope instance."""
        return Telescope(n=256, r=10, snr=40)

    def test_initialization(self, telescope: Telescope) -> None:
        """Test telescope initializes with correct parameters."""
        assert telescope.n == 256
        assert telescope.r == 10
        assert telescope.snr == 40

    def test_mask_creation(self, telescope: Telescope) -> None:
        """Test mask creation produces correct shape and type."""
        mask = telescope.mask([0, 0], 10)

        assert isinstance(mask, Tensor)
        assert mask.shape == (256, 256)
        assert mask.dtype == torch.bool
        assert mask.sum() > 0  # Mask is not empty

    def test_mask_center(self, telescope: Telescope) -> None:
        """Test mask is properly centered."""
        mask = telescope.mask([0, 0], 10)
        center_idx = 256 // 2
        assert mask[center_idx, center_idx] == True

    @pytest.mark.parametrize("radius", [5, 10, 20, 50])
    def test_mask_radius(self, telescope: Telescope, radius: int) -> None:
        """Test different radii produce expected mask areas."""
        mask = telescope.mask([0, 0], radius)

        # Calculate expected vs actual area
        expected_area = 3.14159 * radius ** 2
        actual_area = mask.sum().item()

        # Allow 10% tolerance for pixelation
        assert abs(actual_area - expected_area) / expected_area < 0.1

    def test_forward_shape(self, telescope: Telescope) -> None:
        """Test forward pass produces correct output shape."""
        input_tensor = torch.randn(1, 1, 256, 256)
        output = telescope(input_tensor, centers=[[0, 0]])

        assert output.shape == (1, 1, 256, 256)

    def test_forward_with_noise(self) -> None:
        """Test telescope with noise produces different outputs."""
        tel = Telescope(n=256, r=10, snr=20)
        input_tensor = torch.randn(1, 1, 256, 256)

        output1 = tel(input_tensor, centers=[[0, 0]])
        output2 = tel(input_tensor, centers=[[0, 0]])

        # With noise, outputs should differ
        assert not torch.allclose(output1, output2)
```

## Fixtures

Create reusable test data in `conftest.py`:

```python
# tests/conftest.py
"""Shared pytest fixtures."""

import pytest
import torch
from torch import Tensor
from pathlib import Path


@pytest.fixture
def sample_image() -> Tensor:
    """Generate a sample test image [1, 1, 256, 256]."""
    return torch.randn(1, 1, 256, 256)


@pytest.fixture
def device() -> torch.device:
    """Get test device (CUDA if available)."""
    return torch.device('cuda' if torch.cuda.is_available() else 'cpu')


@pytest.fixture
def test_data_dir(tmp_path: Path) -> Path:
    """Create temporary directory for test data."""
    data_dir = tmp_path / "data"
    data_dir.mkdir()
    return data_dir


@pytest.fixture
def small_telescope():
    """Create small telescope for fast tests."""
    from prism.core.telescope import Telescope
    return Telescope(n=64, r=5)
```

## Parametrize for Multiple Inputs

```python
@pytest.mark.parametrize("n,r,expected", [
    (64, 5, (64, 64)),
    (128, 10, (128, 128)),
    (256, 20, (256, 256)),
])
def test_telescope_sizes(n: int, r: int, expected: tuple[int, int]) -> None:
    """Test telescope handles different sizes."""
    tel = Telescope(n=n, r=r)
    mask = tel.mask([0, 0], r)
    assert mask.shape == expected
```

## Testing PyTorch Operations

```python
def test_fft_inverse_property() -> None:
    """Test FFT followed by IFFT returns original."""
    from prism.utils.transforms import fft, ifft

    image = torch.randn(1, 1, 256, 256)
    result = ifft(fft(image))

    assert torch.allclose(result, image, rtol=1e-5, atol=1e-7)


def test_fft_parseval_theorem() -> None:
    """Test Parseval's theorem: energy preserved in FFT."""
    from prism.utils.transforms import fft

    image = torch.randn(1, 1, 256, 256)

    spatial_energy = image.pow(2).sum()
    freq_energy = fft(image).abs().pow(2).sum()

    assert torch.allclose(spatial_energy, freq_energy, rtol=1e-4)
```

## Edge Cases and Error Handling

```python
def test_invalid_input_shape() -> None:
    """Test function raises error for invalid input shape."""
    from prism.core.telescope import Telescope

    tel = Telescope(n=256, r=10)
    invalid_input = torch.randn(256, 256)  # Missing batch and channel dims

    with pytest.raises(AssertionError, match="Expected 4D tensor"):
        tel(invalid_input, centers=[[0, 0]])


def test_empty_centers_list() -> None:
    """Test handling of empty centers list."""
    from prism.core.telescope import Telescope

    tel = Telescope(n=256, r=10)
    image = torch.randn(1, 1, 256, 256)

    # Should handle gracefully or raise clear error
    with pytest.raises(ValueError, match="centers cannot be empty"):
        tel(image, centers=[])
```

## Integration Test Pattern

For testing data flow:

```python
# tests/integration/test_training_pipeline.py
"""Integration tests for full training pipeline."""

def test_complete_training_cycle(tmp_path: Path) -> None:
    """Test end-to-end training completes successfully."""
    from prism.training import Trainer
    from prism.config import ExperimentConfig

    # Minimal config for fast test
    config = ExperimentConfig(
        image_size=64,
        n_samples=10,
        n_epochs=5
    )

    trainer = Trainer(config, output_dir=tmp_path)
    trainer.train()

    # Verify outputs exist
    assert (tmp_path / "checkpoints").exists()
    assert (tmp_path / "metrics").exists()
    assert len(list((tmp_path / "checkpoints").glob("*.pt"))) > 0
```

## Mocking External Dependencies

```python
from unittest.mock import Mock, patch

def test_with_mocked_telescope() -> None:
    """Test using mocked telescope for isolated testing."""
    from prism.models import ProgressiveDecoder

    mock_telescope = Mock()
    mock_telescope.return_value = torch.ones(1, 1, 256, 256)

    with patch('prism.models.Telescope', return_value=mock_telescope):
        model = ProgressiveDecoder()
        result = model()

        assert result.shape == (1, 1, 256, 256)
```

## Test Organization

```
tests/
├── conftest.py              # Shared fixtures
├── unit/                    # Unit tests
│   ├── test_telescope.py
│   ├── test_grid.py
│   ├── test_networks.py
│   └── test_transforms.py
└── integration/             # Integration tests
    ├── test_training.py
    └── test_data_flow.py
```

## Running Tests

```bash
# Run all tests
uv run pytest

# Run specific test file
uv run pytest tests/unit/test_telescope.py

# Run with coverage
uv run pytest --cov=prism --cov-report=html

# Run only parametrized tests
uv run pytest -k "test_mask_radius"

# Verbose output
uv run pytest -v

# Stop on first failure
uv run pytest -x
```

## Checklist

For each test file:
- [ ] Clear test class and method names
- [ ] Fixtures for reusable test data
- [ ] Parametrize for multiple scenarios
- [ ] Test both success and failure cases
- [ ] Assert specific error messages
- [ ] Clean up resources (tmp files, etc.)
- [ ] Tests are independent (no shared state)
- [ ] Fast execution (< 1s per test ideally)
