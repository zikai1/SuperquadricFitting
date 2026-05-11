function [p] = fuzzy_correspendence(dist, sigma2, w, p0,lambda)
%==================================
% fuzzy correspondence calculation
%==================================
    c = (2 * pi * sigma2) ^ (- 3 / 2);
    const = (w * p0) / (c * (1 - w));
    p = exp(-1 /(sigma2*lambda) * dist.^ 2);
    p = p ./ (p+const);

end