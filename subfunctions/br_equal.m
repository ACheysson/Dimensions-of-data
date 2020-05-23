function [price_s, market, profits] = br_equal(p_grid, future_gain, future_loss, alpha, graphs)

% This function computes the best response schedule of the uninformed
% platform to prices contains in the price grid p_grid. The uninformed firm
% is assume to believe it encounters other firms types with
% equiprobability.
%
% input:
%   p_grid      [mat] --> Contains all the values of the opponent's price
%   future_gain [num] --> The value of having the info while your opponent
%                         does not have it
%   future_loss [num] --> The value of not having the info while your
%                         opponent gets it
%   alpha       [num] --> Degree of horizontal differentiation
%   prior       [num] --> Between 0.5 and 1, assuming a symmetric markov matrix
%   graph       [num] --> 1 to get graph display, 0 otherwise
% output:
%   price_s     [mat] --> for price star, contains the best response in a vector
%   market      [mat] --> Market share, a two column matrix for type 1, type 2
%   profits     [mat] --> Profits corresponding to the schedule of prices.

% This serves to remove the printed output of fmincon. This function is
% usually used in a loop so I replaced it with warnings in case of trouble
options = optimoptions('fmincon', 'Display','off', 'OptimalityTolerance', 1e-10);


% Instantiate empty vectors for the loop over opponent's price
fineness = length(p_grid);                  % The number of ticks in the grid
price_s = zeros(fineness,1);                % The empty vector of optimal prices
market = zeros(fineness,1);                 % Three columns for type 1, 2.
profits = zeros(fineness,1);                % Expected profits

% Start looping over possible value for competitor
for ii = 1:fineness
    % Change p_b
    p_b = p_grid(ii);
    
    % We write three functions, they corresponds to the probability of
    % delivering more utility than the opponent firm
    
    % This is the probability that you deliver positive utility in good match
    p_good = @(x) (x>alpha)*(alpha+1-x)+(x<=alpha);
    
    % Probability that you deliver a positive utility in wrong match
    p_bad = @(x) ((x<1)*(1-x));
    
    
    % This is probability to get consumer, when both firms are serving the
    % same good, when using price x against price b
    p_equal = @(x) ((x-p_b >= 0)*  (x-p_b<=1) *   (1/2-(x-p_b)+(x-p_b)^2/2) + ...       % Probability of getting the consumer with x superior to p_b but not by 1
                   (x-p_b <  0)*  (p_b-x<=1) *   (1/2-(x-p_b)-(x-p_b)^2/2) + ...       % Probability of getting the consumer with x inferior to p_b but not by 1
                   (x-p_b <  0)*  (p_b-x>1));                                          % You get all consumers if you undercut rival by more than 1
               
    % This is the probability to get the consumer, when you serve the wrong
    % content and the opponent the right content
    p_inf = @(x) ((x + alpha - p_b >=0)  *  (x+alpha-p_b<=1) * (1/2-(x+alpha-p_b)+(x+alpha-p_b)^2/2) + ...   % Probability of getting the consumer with x superior to p_b but not by 1 knowing the other matches well and you don't
                 (x + alpha - p_b <0)   *  (-alpha+p_b-x<=1) * (1/2-(x+alpha-p_b)-(x+alpha-p_b)^2/2) + ...   % Probability of getting the consumer with x inferior to p_b but not by 1 + alpha
                 (x + alpha - p_b <0)   *  (-alpha+p_b-x>1));                                                % You get all consumers if you undercut rival by more than 1 - alpha
             
    % This is the probability to get the consumer when you serve the right
    % content and the opponent serves the wrong one
    p_sup = @(x) ((x - alpha - p_b >=0) *  (x-alpha-p_b<=1) * (1/2-(x-alpha-p_b)+(x-alpha-p_b)^2/2) + ...   % Probability of getting the consumer with x superior to p_b but not by 1 + alpha
                 (x - alpha - p_b <0)   *  (alpha+p_b-x<=1) * (1/2-(x-alpha-p_b)-(x-alpha-p_b)^2/2) + ...   % Probability of getting the consumer with x inferior to p_b but not by 1 + alpha
                 (x - alpha - p_b <0)   *  (alpha+p_b-x>1));                                                % You get all consumers because you undercut rival by 1 - alpha
    
    % Compute the expected market share of each type
    market_each =  @(x) [0.5*p_good(x), 0.5*p_bad(x)] * ... % The mass of agent A that joins you weighted by proba you play A
                    [p_sup(x), p_equal(x);              % times if the other plays B, if the other plays A
                     p_equal(x), p_inf(x)] * ...        % times if the other plays B, if the other plays A
                     [0.5;                              % Proba if plays B
                      0.5];                             % Proba if plays A
                  
    % Compute the market share that will remain unserved.
    market_none = @(x) [0.5*(1-p_good(x)), 0.5*(1-p_bad(x))] * ... % Mass of agents unserved times the probability of playing
                       [0.5*((1-p_good(x)) + (1-p_bad(x)));
                        0.5*((1-p_good(x)) + (1-p_bad(x)))];       % Probability of the other guy not serving

    % Write the maximization function                   
    to_max = @(x) -(x + future_gain)*2*market_each(x) - future_loss*2*market_none(x);
                                        
    % Find the maximum
    [price_s(ii), ~, error_info] = fmincon(to_max, p_b, -1, 0, [], [], [], [], [], options);

    % Distribute the values
    market(ii) = market_each(price_s(ii))*2; 
    profits(ii) =  price_s(ii)*market(ii);
    
    % Fire a warning in case of error (I suppressed the output so it's
    % important to do so)
    if ~find(error_info == [1,2])
        warning('Optimizer did not properly work for the response of the uninform firm')
    end
end

if graphs == 1
    figure
    yyaxis left
    plot(p_grid, price_s)
    hold on
    plot(p_grid, p_grid)
    yyaxis right
    plot(p_grid, market)
    hold on
    plot(p_grid, profits)
    legend('Price', 'Fixed line', 'Expected Market share', 'Expected Profits')
end
end