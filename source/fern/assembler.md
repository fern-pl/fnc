```
int foo = 3;

while (foo-- > 0)
    return += foo * 10;

return ^^= 2;
return -= foo;
```

```
    mov foo, 3
    xor return, return

loop:
    sub foo, 1
    mov foo_temp, foo
    mul foo_temp, 10
    add return, foo_temp
    cmp foo, 0
    jg loop

    imul return, return
    sub return, foo
    ret
```