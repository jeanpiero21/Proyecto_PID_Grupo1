function d = distanciaSat(s, R)
%DISTANCIASAT Diferencia absoluta mínima entre la saturación media del cajón y la de sus
%   K referencias vacías.  s : N x 1,  R : K x 1  ->  d : N x 1
d = min(abs(double(s(:)) - double(R(:))'), [], 2);
end
