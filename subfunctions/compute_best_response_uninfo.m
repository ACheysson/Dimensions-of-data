function [sols, market_share_type_1, market_share_type_2, profits] = compute_best_response_uninfo(p_grid, alpha, s_1, activate)


options = optimoptions('fmincon', 'Display','off');
fineness = length(p_grid);
sols = zeros(fineness,1);
market_share_type_1 = zeros(fineness,2);
market_share_type_2 = zeros(fineness,2);
full_market_share = zeros(fineness,2);
profits = zeros(fineness,2);


for ii = 1:fineness
    % Change p_b
    p_b = p_grid(ii);
    
    % Re-write the function
    exp_util_other = @(p_a) - p_a * ...   % The price you charge
                            (0.5 * ...   % Probability that the other platform has received information [0.8, 0.2] and will serve good A.
                                (0.5 * ...    % Probability that you serve good A
                                    (s_1 * ...    % The mass of agent consuming good A
                                        (( p_a > alpha )* (alpha+1-p_a) + (p_a <= alpha)) * ...                       % Probability of the good A delivering utility to agents of type A
                                        ((p_a-p_b >= 0)*  (p_a-p_b<=1) *   (1/2-(p_a-p_b)+(p_a-p_b)^2/2) + ...      % Probability of getting the consumer with p_a superior to p_b but not by 1
                                        (p_a-p_b <  0)*  (p_b-p_a<=1) *   (1/2-(p_a-p_b)-(p_a-p_b)^2/2) + ...       % Probability of getting the consumer with p_a inferior to p_b
                                        (p_a-p_b <  0)*  (p_b-p_a>1)) + ...                                         % Probability that you're price is so low you get everything
                                    (1-s_1)* ...      % The mass of agent consuming good 2
                                        ((p_a<1)*(1-p_a))* ...                                                       % Probability of the good delivering utility to type B knowing you deliver A
                                        ((p_a-p_b >= 0)*  (p_a-p_b<=1) *   (1/2-(p_a-p_b)+(p_a-p_b)^2/2) + ...       % Probability of getting the consumer with p_a superior to p_b but not by 1
                                        (p_a-p_b <  0)*  (p_b-p_a<=1) *    (1/2 - (p_a-p_b) - (p_a-p_b)^2/2) + ...   % Probability of getting the consumer with p_a inferior to p_b
                                        (p_a-p_b <  0)*  (p_b-p_a>1))) + ...                                         % Probability that you're price is so low you get everything
                                (0.5 * ...   % Probabiltity that you serve good B
                                    (s_1 * ...   % Mass of agents consuming good A
                                        ((p_a<1)*(1-p_a))* ...                                                                              % Probability of the good delivering utility to type A knowing you deliver B
                                        ((p_a + alpha - p_b >=0)  *  (p_a+alpha-p_b<=1) * (1/2-(p_a+alpha-p_b)+(p_a+alpha-p_b)^2/2) + ...   % Probability of getting the consumer with p_a superior to p_b but not by 1 knowing the other matches well and you don't
                                        (p_a + alpha - p_b <0)   *  (-alpha+p_b-p_a<=1) * (1/2-(p_a+alpha-p_b)-(p_a+alpha-p_b)^2/2) + ...
                                        (p_a + alpha - p_b <0)   *  (-alpha+p_b-p_a>1)) + ...
                                    (1-s_1) * ...
                                        (( p_a > alpha )* (alpha+1-p_a) + (p_a <= alpha)) * ...
                                        ((p_a - alpha - p_b >=0)  *  (p_a-alpha-p_b<=1) * (1/2-(p_a-alpha-p_b)+(p_a-alpha-p_b)^2/2) + ...   % Probability of getting the consumer with p_a superior to p_b but not by 1
                                        (p_a - alpha - p_b <0)   *  (alpha+p_b-p_a<=1) * (1/2-(p_a-alpha-p_b)-(p_a-alpha-p_b)^2/2) + ...
                                        (p_a - alpha - p_b <0)   *  (alpha+p_b-p_a>1))))) + ...
                             0.5 * ...      % Probability that the other platform has received information [0.2, 0.8] and will serve good B.
                                (0.5 * ...                                                       % The probability that you serve good A
                                    ((1-s_1) * ...                                               % The mass of agent A
                                        (( p_a > alpha )* (alpha+1-p_a) + (p_a <= alpha)) * ...  % Probability of the good A delivering utility to agents of type A
                                        ((p_a - alpha - p_b >=0)  *  (p_a-alpha-p_b<=1) * (1/2-(p_a-alpha-p_b)+(p_a-alpha-p_b)^2/2) + ...   % Probability of getting the consumer with p_a superior to p_b but not by 1
                                        (p_a - alpha - p_b <0)   *  (alpha+p_b-p_a<=1) * (1/2-(p_a-alpha-p_b)-(p_a-alpha-p_b)^2/2) + ...
                                        (p_a - alpha - p_b <0)   *  (alpha+p_b-p_a>1)) + ...
                                    s_1 * ...                                                   % The mass of agent B
                                        ((p_a<1)*(1-p_a))* ... 
                                        ((p_a + alpha - p_b >=0)  *  (p_a+alpha-p_b<=1) * (1/2-(p_a+alpha-p_b)+(p_a+alpha-p_b)^2/2) + ...   % Probability of getting the consumer with p_a superior to p_b but not by 1 knowing the other matches well and you don't
                                        (p_a + alpha - p_b <0)   *  (-alpha+p_b-p_a<=1) * (1/2-(p_a+alpha-p_b)-(p_a+alpha-p_b)^2/2) + ...
                                        (p_a + alpha - p_b <0)   *  (-alpha+p_b-p_a>1))) + ...
                                 0.5 * ...                                                      % The probability that you serve good B
                                    ((1-s_1) * ...  % Mass of agent A
                                        ((p_a<1)*(1-p_a))* ...  % Probability that your good delivers utility to agents A
                                        ((p_a-p_b >= 0)*  (p_a-p_b<=1) *   (1/2-(p_a-p_b)+(p_a-p_b)^2/2) + ...       % Probability of getting the consumer with p_a superior to p_b but not by 1
                                        (p_a-p_b <  0)*  (p_b-p_a<=1) *    (1/2 - (p_a-p_b) - (p_a-p_b)^2/2) + ...   % Probability of getting the consumer with p_a inferior to p_b
                                        (p_a-p_b <  0)*  (p_b-p_a>1))) + ...
                                    s_1 * ...
                                        (( p_a > alpha )* (alpha+1-p_a) + (p_a <= alpha)) * ...  % Probability of the good A delivering utility to agents of type A
                                        ((p_a-p_b >= 0)*  (p_a-p_b<=1) *   (1/2-(p_a-p_b)+(p_a-p_b)^2/2) + ...       % Probability of getting the consumer with p_a superior to p_b but not by 1
                                        (p_a-p_b <  0)*  (p_b-p_a<=1) *    (1/2 - (p_a-p_b) - (p_a-p_b)^2/2) + ...   % Probability of getting the consumer with p_a inferior to p_b
                                        (p_a-p_b <  0)*  (p_b-p_a>1))));
    % Let's find the equilibrium
    
    sols(ii) = fmincon(exp_util_other, p_grid(ii), -1, 0, [], [], [], [], [], options);
    
    % We can compute expected market shares, there are a lot more,
    % depending on the type of the other
    p_a = sols(ii);
    
    % Those are the market shares in the event you are against type A other
    % platform, otherwise you just reverse it
    market_share_type_1(ii,1) = 0.5 * ...    % Probability that you serve good A
                                    (( p_a > alpha )* (alpha+1-p_a) + (p_a <= alpha)) * ...                       % Probability of the good A delivering utility to agents of type A
                                    ((p_a-p_b >= 0)*  (p_a-p_b<=1) *   (1/2-(p_a-p_b)+(p_a-p_b)^2/2) + ...      % Probability of getting the consumer with p_a superior to p_b but not by 1
                                    (p_a-p_b <  0)*  (p_b-p_a<=1) *   (1/2-(p_a-p_b)-(p_a-p_b)^2/2) + ...       % Probability of getting the consumer with p_a inferior to p_b
                                    (p_a-p_b <  0)*  (p_b-p_a>1)) + ...
                                0.5 * ...    % Probability that you serve good B
                                    ((p_a<1)*(1-p_a))* ...                                                                              % Probability of the good delivering utility to type A knowing you deliver B
                                    ((p_a + alpha - p_b >=0)  *  (p_a+alpha-p_b<=1) * (1/2-(p_a+alpha-p_b)+(p_a+alpha-p_b)^2/2) + ...   % Probability of getting the consumer with p_a superior to p_b but not by 1 knowing the other matches well and you don't
                                    (p_a + alpha - p_b <0)   *  (-alpha+p_b-p_a<=1) * (1/2-(p_a+alpha-p_b)-(p_a+alpha-p_b)^2/2) + ...
                                    (p_a + alpha - p_b <0)   *  (-alpha+p_b-p_a>1));
                                
    market_share_type_1(ii,2) = 0.5 * ...    % Probability that you serve good A
                                    ((p_a<1)*(1-p_a))* ...                                                      % Probability of the good A delivering utility to agents of type B
                                    ((p_a-p_b >= 0)*  (p_a-p_b<=1) *   (1/2-(p_a-p_b)+(p_a-p_b)^2/2) + ...      % Probability of getting the consumer with p_a superior to p_b but not by 1
                                    (p_a-p_b <  0)*  (p_b-p_a<=1) *   (1/2-(p_a-p_b)-(p_a-p_b)^2/2) + ...       % Probability of getting the consumer with p_a inferior to p_b
                                    (p_a-p_b <  0)*  (p_b-p_a>1)) + ...
                                0.5 * ...    % Probability that you serve good B
                                    (( p_a > alpha )* (alpha+1-p_a) + (p_a <= alpha)) * ...                     % Probability of the good B delivering utility to agents of type B
                                    ((p_a-alpha-p_b >= 0)*  (p_a-alpha-p_b<=1) *   (1/2-(p_a-alpha-p_b)+(p_a-alpha-p_b)^2/2) + ...      % Probability of getting the consumer with p_a superior to p_b but not by 1
                                    (p_a-alpha-p_b <  0)*  (alpha+p_b-p_a<=1) *   (1/2-(p_a-alpha-p_b)-(p_a-alpha-p_b)^2/2) + ...       % Probability of getting the consumer with p_a inferior to p_b
                                    (p_a-alpha-p_b <  0)*  (alpha+p_b-p_a>1));
                               
    % You just reverse thanks to symmetry
	market_share_type_2(ii,1) = market_share_type_1(ii,2);
    market_share_type_2(ii,2) = market_share_type_1(ii,1);
     
    full_market_share(ii,1) = s_1*market_share_type_1(ii,1) + (1-s_1)*market_share_type_1(ii,2);
    full_market_share(ii,2) = (1-s_1)*market_share_type_2(ii,1) + s_1*market_share_type_2(ii,2);
    profits(ii) = p_a * full_market_share(ii,1);
end

if activate == 1
    % Do a simple plot
    figure
    yyaxis left
    plot(p_grid, sols)
    hold on
    plot(p_grid, p_grid)
    ylabel('Best Response')
    yyaxis right
    plot(p_grid, full_market_share(:,1))
    hold on
    plot(p_grid, profits)
    ylabel('Profits/Market share')
    xlabel('Price of opponent')
    legend('Price', '45° line', 'Expected Market share', 'Expected Profits')
end
end
