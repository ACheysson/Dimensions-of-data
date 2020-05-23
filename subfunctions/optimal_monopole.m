function [optimal_price, market_share, profits, consumer_surplus] = optimal_monopole(voi, prior, alpha)

% Solves the monopolist problem, the function is adaptable to be used
% at any period of the model. 
%
% input:
%   voi   [num] --> Value from information, put to 0 if period 2.
%   prior [num] --> This is the expected number for majority agent.
%   alpha [num] --> This is the degree of horizontal differentiation.
% output:
%   optimal_price [num] --> The price that solves the maximization problem
%   market_share  [mat] --> Expected market share of types one, two, and overall
%   profits       [num] --> Expected profits at optimal price


% Set option of the optimizer function, we remove display and simply fire a
% warning in case of problems
options = optimoptions('fmincon', 'Display','off', 'OptimalityTolerance', 1e-10);


% We first need to write the function optimized upon by the firm.
profits = @(p) - (p+voi) * ...                                     % Profit extracted from each agent (intensive margin)
                 (prior*((p>alpha )*(alpha+1-p)+(p<=alpha)) + ...  % Probability of majority agent to like the good when good match
                 (1-prior)*(p<1)*(1-p));                           % Probability of minority agent getting the good (bad match)
             
% Find the maximum
[optimal_price,profits,error_info] = fmincon(profits, alpha/2, -1, 0, [], [], [], [], [], options);
profits = -profits; % The function solves for the minimum

% Return a warning in case of a problem
if error_info ~= 2 && error_info ~= 3
    warning('There might have been a problem with optimization')
end

% Compute the market shares
market_share = zeros(3,1);
market_share(1) = (optimal_price>alpha)*(alpha+1-optimal_price)+(optimal_price<=alpha);
market_share(2) = (optimal_price<1)*(1-optimal_price);
market_share(3) = prior*market_share(1) + (1-prior)*market_share(2);

% Compute the consumer surplus of majority agent
consumer_surplus(1) = (optimal_price<=alpha) * ...                                          % If p<alpha everyone is getting utility from consumption
                       (alpha-optimal_price + 0.5) + ...                                    % and this is the utility they derive from it
                       (optimal_price>alpha) * ...                                          % Not all agents derive utility 
                            (alpha+1-optimal_price) * ...                                   % This is the mass that does derive utility
                                (1/2 - (optimal_price-alpha) - (optimal_price-alpha)^2/2);  % And this is the utility they derive on expectation
% Compute consumer surplus of minority agent
consumer_surplus(2) = (optimal_price<1)*(1-optimal_price) * ... % The mass of agent that actually enjoys the good
                      (1/2 - optimal_price - optimal_price^2/2);
                  
% Compute the optimal surplus
consumer_surplus = prior*consumer_surplus(1) + (1-prior)*consumer_surplus(2);

end





                 



