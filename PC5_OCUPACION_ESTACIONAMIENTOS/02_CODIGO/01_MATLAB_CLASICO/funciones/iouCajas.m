function M = iouCajas(A, B)
%IOUCAJAS Intersección sobre unión entre cajas [x y w h]: M(i,j) = IoU(A(i,:), B(j,:)).
x1 = max(A(:,1), B(:,1)');
y1 = max(A(:,2), B(:,2)');
x2 = min(A(:,1) + A(:,3), (B(:,1) + B(:,3))');
y2 = min(A(:,2) + A(:,4), (B(:,2) + B(:,4))');
inter = max(x2 - x1, 0) .* max(y2 - y1, 0);
union = A(:,3).*A(:,4) + (B(:,3).*B(:,4))' - inter;
M = inter ./ max(union, eps);
end
