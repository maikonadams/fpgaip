function im2d = mosaic(im3d,cfa)
[m,n,p] = size(im3d);
assert(p == 3)
im2d = zeros(m,n,class(im3d));
[row,col,page] = pattern(cfa);
for pos = 1:numel(page)
    i = row(pos):2:m;
    j = col(pos):2:n;
    k = page(pos);
    im2d(i,j) = im3d(i,j,k);
end

function [row,col,page] = pattern(cfa)
row = [1 1 2 2];
col = [1 2 1 2];
switch cfa
    case 'gbrg'
        page = [2 3 1 2];
    case 'grbg'
        page = [2 1 3 2];
    case 'bggr'
        page = [3 2 2 1];
    case 'rggb'
        page = [1 2 2 3];
    otherwise
        error('Unsupported CFA pattern.')
end
