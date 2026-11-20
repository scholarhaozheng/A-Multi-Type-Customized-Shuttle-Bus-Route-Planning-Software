function option = GeneratingOperatorsChoice(i,lambda,desORrep,omega)
% Roulette selection over the supplied implemented operators.
weights = omega(:)';
if isempty(weights) || any(~isfinite(weights)) || any(weights < 0) || sum(weights) <= 0
    error('MDVRPTW:OperatorWeights','Operator weights must be finite, nonnegative, and have a positive sum.');
end
cumulative = cumsum(weights/sum(weights));
cumulative(end) = 1;
option = find(rand() < cumulative,1);
end
