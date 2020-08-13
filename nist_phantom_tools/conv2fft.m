function c = conv2fft(a,b)
%
% Circular convolution with padding
%

  [ma, na] = size(a);
  [mb, nb] = size(b);
 
  mc = max(ma,mb);
  nc = max(na,nb);

  ap = zeros(mc,nc);
  bp = zeros(mc,nc);

  ap(1:ma,1:na) = a;
  bp(1:mb,1:nb) = b;

  c = ifft2(fft2(ap).*fft2(bp));

  if( isreal(a) && isreal(b) ) c = real(c); end

end
