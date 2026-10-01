-- @name     高对比
-- @author   vii3
-- @desc     内置高对比曲线（contrast 合法范围 -1~1）
-- @version  1.0
-- @builtin  no
-- @needs    none
-- @oneshot  no

-- 高对比：contrast 合法范围 -1~1（0 = 不变，越界会被夹住并记日志）
-- 它在"线性光"里算，所以 contrast = -1 得到的是平场 188 而不是 128
return {
  { highContrast = { contrast = 0.5 } },
}
