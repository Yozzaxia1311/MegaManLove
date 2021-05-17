local self, super, other = ...

if other:is(megaBuster) then
  return -1
elseif other:is(megaSemiBuster) then
  return megautils.diffValue(-1, {easy=-2})
elseif other:is(megaChargedBuster) then
  return megautils.diffValue(-2, {easy=-3})
elseif other:is(protoSemiBuster) then
  return megautils.diffValue(-1, {easy=-2})
elseif other:is(protoChargedBuster) then
  return megautils.diffValue(-2, {easy=-3})
elseif other:is(bassBuster) then
  if other.treble then
    return megautils.diffValue(-1, {easy=-2})
  else
    return megautils.diffValue(-0.5, {easy=-1})
  end
end