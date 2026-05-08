---
name: go-nil
description: Go nil safety patterns. Routes to specific traps.
---

# Nil Safety

## Route by Type
- Interface nil trap → see [interface/](interface/)
- Map nil writes → see [map/](map/)
- Slice zero-value → see [slice/](slice/)
- Pointer receivers → see [pointer/](pointer/)

## Quick Check
- [ ] Check pointers before deref
- [ ] Check maps before write
- [ ] Typed nil != nil interface

## Common Gotcha
```go
var p *int
if p == nil {  // true
    fmt.Println("nil pointer")
}
```
