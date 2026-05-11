 function [value] = weighted_dist(para, X, p, deformable)

        value = p .^ (1 / 2).* distance_deformable(X, para,deformable);

    end