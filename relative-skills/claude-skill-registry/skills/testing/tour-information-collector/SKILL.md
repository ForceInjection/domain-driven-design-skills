---
name: "Tour Information Collector"
description: "Collects latest tour information and travel insights for a specific destination using Perplexity API"
---

# Tour Information Collector

## Instructions
- Dùng Perplexity để lấy thông tin tour/cẩm nang mới nhất (ưu tiên 7-30 ngày gần đây) cho một địa điểm.
- Trả kết quả tiếng Việt dưới dạng JSON: { destination, highlights[], typical_prices, best_time, tips[], sources[] }.
- Ưu tiên nguồn uy tín; sắp xếp mới nhất trước.
- Nếu API lỗi hoặc không có dữ liệu, trả về thông báo ngắn gọn theo schema (error message).

## Examples
- User: "cho mình thông tin tour mới nhất ở Đà Lạt"
- Query: "Tìm thông tin mới nhất về tour du lịch tại Đà Lạt gồm: điểm tham quan nổi bật, giá tour phổ biến, thời gian tốt nhất để đi, lưu ý du lịch. Trả lời tiếng Việt."
