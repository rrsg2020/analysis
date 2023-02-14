function [row,col,p]=rowcol(a)
%
% find row and column indices of nonzero entries in a
%

  [nx,ny] = size(a);

  p = find(a~=0);
  [row, col] = ind2sub([nx,ny], p);

end
