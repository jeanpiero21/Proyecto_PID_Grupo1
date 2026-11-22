function d = distanciaHOG(P, R)
%DISTANCIAHOG 1 - máxima similitud coseno entre el HOG del cajón y las K referencias vacías.
%   P : N x 216 (vectores HOG normalizados),  R : K x 216  ->  d : N x 1
%   d ~ 0: la estructura de bordes es la del cajón vacío (líneas, asfalto); d alto: un auto.
d = 1 - max(double(P) * double(R)', [], 2);
end
