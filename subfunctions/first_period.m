function [sols, market_share] = first_period(p_grid, future_gain, alpha, graphs)

%
%
%
%
%
%

options = optimoptions('fmincon', 'Display','off', 'OptimalityTolerance', 1e-10);
fineness = length(p_grid);
sols = zeros(fineness,1);
market_share = zeros(fineness,1);
profits = zeros(fineness,2);


for ii = 1:fineness
    % Change p_b
    p_b = p_grid(ii);
    exp_util_other = @(p_a) -(p_a+future_gain)* ...   % The utilty you extract out of every guy
                            	(0.5 * ...                   % The probability you play A
                                    (0.5 * ...               % The probability the other plays A
                                        (0.5 * ...           % The mass of agents A
                                            (( p_a > alpha )* (alpha+1-p_a) + (p_a <= alpha)) * ...                     % Probability of the good A delivering utility to agents of type A
                                            ((p_a-p_b >= 0)*  (p_a-p_b<=1) *   (1/2-(p_a-p_b)+(p_a-p_b)^2/2) + ...      % Probability of getting the consumer with p_a superior to p_b but not by 1
                                            (p_a-p_b <  0)*  (p_b-p_a<=1) *   (1/2-(p_a-p_b)-(p_a-p_b)^2/2) + ...       % Probability of getting the consumer with p_a inferior to p_b
                                            (p_a-p_b <  0)*  (p_b-p_a>1)) + ...                                         % Probability that you're price is so low you get everything
                                        0.5 * ...            % The mass of agents B
                                            ((p_a<1)*(1-p_a))* ...                                                      % Probability of the good A delivering utility to agents of type B
                                            ((p_a-p_b >= 0)*  (p_a-p_b<=1)* (1/2-(p_a-p_b)+(p_a-p_b)^2/2) + ...      % Probability of getting the consumer with p_a superior to p_b but not by 1
                                            (p_a-p_b <  0)*  (p_b-p_a<=1) *   (1/2-(p_a-p_b)-(p_a-p_b)^2/2) + ...       % Probability of getting the consumer with p_a inferior to p_b
                                            (p_a-p_b <  0)*  (p_b-p_a>1))) + ...
                                    0.5 * ...               % The probability the other plays B
                                        (0.5* ...           % The mass of agents A
                                            (( p_a > alpha )* (alpha+1-p_a) + (p_a <= alpha)) * ...                     % Probability of the good A delivering utility to agents of type A
                                            ((p_a - alpha - p_b >=0)  *  (p_a-alpha-p_b<=1) * (1/2-(p_a-alpha-p_b)+(p_a-alpha-p_b)^2/2) + ...   % Probability of getting the consumer with p_a superior to p_b but not by 1
                                            (p_a - alpha - p_b <0)   *  (alpha+p_b-p_a<=1) * (1/2-(p_a-alpha-p_b)-(p_a-alpha-p_b)^2/2) + ...
                                            (p_a - alpha - p_b <0)   *  (alpha+p_b-p_a>1)) + ...
                                        0.5* ...            % The mass of agent B
                                            ((p_a<1)*(1-p_a))* ...
                                            ((p_a + alpha - p_b >=0)  *  (p_a+alpha-p_b<=1) * (1/2-(p_a+alpha-p_b)+(p_a+alpha-p_b)^2/2) + ...   % Probability of getting the consumer with p_a superior to p_b but not by 1 knowing the other matches well and you don't
                                            (p_a + alpha - p_b <0)   *  (-alpha+p_b-p_a<=1) * (1/2-(p_a+alpha-p_b)-(p_a+alpha-p_b)^2/2) + ...
                                            (p_a + alpha - p_b <0)   *  (-alpha+p_b-p_a>1)))) + ...
                                0.5 * ...               % The probability that you play B
                                    (0.5 * ...               % The probability the other plays A
                                        (0.5 * ...           % The mass of agents A
                                            ((p_a<1)*(1-p_a)) * ...       % Probability of the good B delivering utility to agents of type A
                                            ((p_a + alpha - p_b >=0)  *  (p_a+alpha-p_b<=1) * (1/2-(p_a+alpha-p_b)+(p_a+alpha-p_b)^2/2) + ...   % Probability of getting the consumer with p_a superior to p_b but not by 1 knowing the other matches well and you don't
                                            (p_a + alpha - p_b <0)   *  (-alpha+p_b-p_a<=1) * (1/2-(p_a+alpha-p_b)-(p_a+alpha-p_b)^2/2) + ...
                                            (p_a + alpha - p_b <0)   *  (-alpha+p_b-p_a>1)) + ...
                                        0.5 * ...            % The mass of agents B
                                            (( p_a > alpha )* (alpha+1-p_a) + (p_a <= alpha)) * ...                     % Probability of the good A delivering utility to agents of type A
                                            ((p_a - alpha - p_b >=0)  *  (p_a-alpha-p_b<=1) * (1/2-(p_a-alpha-p_b)+(p_a-alpha-p_b)^2/2) + ...   % Probability of getting the consumer with p_a superior to p_b but not by 1
                                            (p_a - alpha - p_b <0)   *  (alpha+p_b-p_a<=1) * (1/2-(p_a-alpha-p_b)-(p_a-alpha-p_b)^2/2) + ...
                                            (p_a - alpha - p_b <0)   *  (alpha+p_b-p_a>1))) + ...
                                     0.5 * ...              % The probability the other plays B
                                        (0.5 * ...          % The mass of agents A
                                            ((p_a<1)*(1-p_a)) * ...
                                            ((p_a-p_b >= 0)*  (p_a-p_b<=1)* (1/2-(p_a-p_b)+(p_a-p_b)^2/2) + ...      % Probability of getting the consumer with p_a superior to p_b but not by 1
                                            (p_a-p_b <  0)*  (p_b-p_a<=1) *   (1/2-(p_a-p_b)-(p_a-p_b)^2/2) + ...       % Probability of getting the consumer with p_a inferior to p_b
                                            (p_a-p_b <  0)*  (p_b-p_a>1)) + ...
                                        0.5 * ...           % The mass of agents B
                                            (( p_a > alpha )* (alpha+1-p_a) + (p_a <= alpha)) * ...                     % Probability of the good A delivering utility to agents of type A
                                            ((p_a-p_b >= 0)*  (p_a-p_b<=1)* (1/2-(p_a-p_b)+(p_a-p_b)^2/2) + ...      % Probability of getting the consumer with p_a superior to p_b but not by 1
                                            (p_a-p_b <  0)*  (p_b-p_a<=1) *   (1/2-(p_a-p_b)-(p_a-p_b)^2/2) + ...       % Probability of getting the consumer with p_a inferior to p_b
                                            (p_a-p_b <  0)*  (p_b-p_a>1)))));
                                        
    % Find the maximum
    sols(ii) = fmincon(exp_util_other, p_b, -1, 0, [], [], [], [], [], options);
    p_a = sols(ii);
    
    % Compute market shares
    market_share(ii) = 0.5 * ...                     % The probability you play A
                         	(0.5 * ...                 % The probability the other plays A
                                 (( p_a > alpha )* (alpha+1-p_a) + (p_a <= alpha)) * ...                     % Probability of the good A delivering utility to agents of type A
                                 ((p_a-p_b >= 0)*  (p_a-p_b<=1) *   (1/2-(p_a-p_b)+(p_a-p_b)^2/2) + ...      % Probability of getting the consumer with p_a superior to p_b but not by 1
                                 (p_a-p_b <  0)*  (p_b-p_a<=1) *   (1/2-(p_a-p_b)-(p_a-p_b)^2/2) + ...       % Probability of getting the consumer with p_a inferior to p_b
                                 (p_a-p_b <  0)*  (p_b-p_a>1)) + ...
                            0.5 * ...                  % The probability the other plays B
                                (( p_a > alpha )* (alpha+1-p_a) + (p_a <= alpha)) * ...                     % Probability of the good A delivering utility to agents of type A
                                ((p_a - alpha - p_b >=0)  *  (p_a-alpha-p_b<=1) * (1/2-(p_a-alpha-p_b)+(p_a-alpha-p_b)^2/2) + ...   % Probability of getting the consumer with p_a superior to p_b but not by 1
                                (p_a - alpha - p_b <0)   *  (alpha+p_b-p_a<=1) * (1/2-(p_a-alpha-p_b)-(p_a-alpha-p_b)^2/2) + ...
                                (p_a - alpha - p_b <0)   *  (alpha+p_b-p_a>1))) + ...
                         0.5 * ...                     % The probability that you play B
                            (0.5 * ...                 % The probability the other plays A
                                ((p_a<1)*(1-p_a))* ... 
                                ((p_a + alpha - p_b >=0)  *  (p_a+alpha-p_b<=1) * (1/2-(p_a+alpha-p_b)+(p_a+alpha-p_b)^2/2) + ...   % Probability of getting the consumer with p_a superior to p_b but not by 1 knowing the other matches well and you don't
                                (p_a + alpha - p_b <0)   *  (-alpha+p_b-p_a<=1) * (1/2-(p_a+alpha-p_b)-(p_a+alpha-p_b)^2/2) + ...
                                (p_a + alpha - p_b <0)   *  (-alpha+p_b-p_a>1)) + ...
                            0.5 * ...                % The probability the other plays B
                                ((p_a<1)*(1-p_a))* ... 
                                ((p_a-p_b >= 0)*  (p_a-p_b<=1) *   (1/2-(p_a-p_b)+(p_a-p_b)^2/2) + ...      % Probability of getting the consumer with p_a superior to p_b but not by 1
                                (p_a-p_b <  0)*  (p_b-p_a<=1) *   (1/2-(p_a-p_b)-(p_a-p_b)^2/2) + ...       % Probability of getting the consumer with p_a inferior to p_b
                                (p_a-p_b <  0)*  (p_b-p_a>1)));
                            
   % All ready to compute profits
   profits(ii) = market_share(ii)*p_a;                      
end

if graphs == 1
    figure
    yyaxis left
    plot(p_grid, sols)
    hold on
    plot(p_grid, p_grid)
    yyaxis right
    plot(p_grid, market_share)
    hold on
    plot(p_grid, profits)
    legend('Price', 'Fixed line', 'Expected Market share', 'Expected Profits')
end
end