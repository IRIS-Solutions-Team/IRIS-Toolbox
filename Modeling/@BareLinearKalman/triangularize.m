function this = triangularize(this)

end%
%{
[U, T] = schur(this.SystemMatrices{1}(:, :, 1));

            [SS, TT, QQ, ZZ] = qz(AA, BB, 'real');
            % Ordered inverse eigvals.
            invEigen = -ordeig(SS, TT);
            invEigen = invEigen(:).';
            isSevn2 = applySevn2Patch( );
            absInvEigen = abs(invEigen);
            indexStableRoots = absInvEigen>=(1+EIGEN_TOLERANCE);
            indexUnitRoots = abs(absInvEigen-1) < EIGEN_TOLERANCE;
            % Clusters of unit, stable, and unstable eigenvalues.
            clusters = zeros(size(invEigen));
            % Unit roots first.
            clusters(indexUnitRoots) = 2;
            % Stable roots second.
            clusters(indexStableRoots) = 1;
            % Unstable roots last.
            % Re-order by the clusters.
            lastwarn('');
            [SS, TT, QQ, ZZ] = ordqz(SS, TT, QQ, ZZ, clusters);
%}
