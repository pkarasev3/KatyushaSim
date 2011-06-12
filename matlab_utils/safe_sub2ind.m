
function ind = safe_sub2ind(sz, rr, cc)
  rr(rr < 1) = 1;
  rr(rr > sz(1)) = sz(1);
  cc(cc < 1) = 1;
  cc(cc > sz(2)) = sz(2);
  ind = sub2ind(sz, rr, cc);
end