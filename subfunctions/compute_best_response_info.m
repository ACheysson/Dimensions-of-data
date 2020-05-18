function [sols, market_share, profits] = compute_best_response_info(p_grid, alpha, s_1)


fineness = length(p_grid);
sols = zeros(fineness,1);
market_share = zeros(fineness,2);
full_market_share = zeros(fineness,1);
profits = zeros(fineness,1);


for ii = 1:fineness
    % Change p_b
    p_b = p_grid(ii);
    
    % Re-write the function
    exp_utility_platform_info = @(p_a) -p_a * ...               % The profit you make on everyone buying
                                            (s_1 * ...          % The mass of agent consuming good A (your signal is correct)
                                                (( p_a > alpha ) * (alpha+1-p_a) + (p_a <= alpha)) * ...    % Probability of agents A buying good A that you propose them
                                                    (0.5 * ...                                              % Probability of the other player playing A 
                                                        ((p_a-p_b >= 0)*  (p_a-p_b<=1) *   (1/2-(p_a-p_b)+(p_a-p_b)^2/2) + ...    % Probability of getting the consumer with p_a superior to p_b but not by 1
                                                        (p_a-p_b < 0)  *  (p_b-p_a<=1) *   (1/2-(p_a-p_b)-(p_a-p_b)^2/2) + ... % Probability of getting the consumer with p_a inferior to p_b
                                                        (p_a-p_b < 0)  *  (p_b-p_a>1)) + ...
                                                     0.5 * ...                                              % Probability of the other player playing B
                                                        ((p_a - alpha - p_b >=0)*   (p_a-alpha-p_b<=1) * (1/2-(p_a-alpha-p_b)+(p_a-alpha-p_b)^2/2) + ...   % Probability of getting the consumer with p_a superior to p_b but not by 1
                                                        (p_a - alpha - p_b <0)   *  (alpha+p_b-p_a<=1) * (1/2-(p_a-alpha-p_b)-(p_a-alpha-p_b)^2/2) + ...
                                                        (p_a - alpha - p_b <0)   *  (alpha+p_b-p_a>1))) + ...
                                             (1-s_1) * ...      % We move to the case where the guy is actually B, so you serve the wrong good
                                                ((p_a<1)*(1-p_a))* ...    % Probability of people buying your good even you serve the wrong good
                                                    (0.5 * ...            % Probability of the other guy playing A as well (so getting it wrong too
                                                        ((p_a-p_b >= 0) *  (p_a-p_b<=1) *   (1/2-(p_a-p_b)+(p_a-p_b)^2/2) + ...      % Probability of getting the consumer with p_a superior to p_b but not by 1
                                                        (p_a-p_b < 0)  *  (p_b-p_a<=1) *    (1/2 - (p_a-p_b) - (p_a-p_b)^2/2) + ...        % Probability of getting the consumer with p_a inferior to p_b
                                                        (p_a-p_b < 0)  *  (p_b-p_a>1)) + ...
                                                     0.5 * ...                                                               % Probability of the other player playing B
                                                        ((p_a + alpha - p_b >=0)  *  (p_a+alpha-p_b<=1) * (1/2-(p_a+alpha-p_b)+(p_a+alpha-p_b)^2/2) + ...   % Probability of getting the consumer with p_a superior to p_b but not by 1
                                                        (p_a + alpha - p_b <0)   *  (-alpha+p_b-p_a<=1) * (1/2-(p_a+alpha-p_b)-(p_a+alpha-p_b)^2/2) + ...
                                                        (p_a + alpha - p_b <0)   *  (-alpha+p_b-p_a>1))));                             % Rest if p_a + 1 - p_b < 0
    
    % Find the maximum
    sols(ii) = fmincon(exp_utility_platform_info, p_grid(ii), -1, 0);
    
    % The proportion of agent A you're taking in
    p_a = sols(ii);
    market_share(ii,1)=(( p_a > alpha ) * (alpha+1-p_a) + (p_a <= alpha)) * ...    % Probability of agents buying your goods knowing your serving them what they want
                            (0.5 * ...                                              % Probability of the other player playing A - Competition is only on price
                            	((p_a-p_b >= 0)  *  (p_a-p_b<=1) *   (1/2-(p_a-p_b)+(p_a-p_b)^2/2) + ...   % Probability of getting the consumer with p_a superior to p_b but not by 1
                                (p_a-p_b < 0)  *  (p_b-p_a<=1) *    (1/2 - (p_a-p_b) - (p_a-p_b)^2/2) + ...        % Probability of getting the consumer with p_a inferior to p_b
                                (p_a-p_b < 0)  *  (p_b-p_a>1)) + ...
                             0.5 * ...                                              % Probability of the other player playing B
                                 ((p_a - alpha - p_b >=0)  *  (p_a-alpha-p_b<=1) * (1/2-(p_a-alpha-p_b)+(p_a-alpha-p_b)^2/2) + ...   % Probability of getting the consumer with p_a superior to p_b but not by 1
                                 (p_a - alpha - p_b <0)   *  (alpha+p_b-p_a<=1) * (1/2-(p_a-alpha-p_b)-(p_a-alpha-p_b)^2/2) + ...
                                 (p_a - alpha - p_b <0)   *  (alpha+p_b-p_a>1)));
                            
	market_share(ii,2) = ((p_a<1)*(1-p_a))* ...    % Probability of people buying your good even you serve the wrong good
                         	(0.5 * ...            % Probability of the other guy playing A as well (so getting it wrong too
                            	((p_a-p_b >= 0) *  (p_a-p_b<=1) *   (1/2-(p_a-p_b)+(p_a-p_b)^2/2) + ...      % Probability of getting the consumer with p_a superior to p_b but not by 1
                                (p_a-p_b < 0)  *  (p_b-p_a<=1) *    (1/2 - (p_a-p_b) - (p_a-p_b)^2/2) + ...        % Probability of getting the consumer with p_a inferior to p_b
                                (p_a-p_b < 0)  *  (p_b-p_a>1)) + ...
                            0.5 * ...                                                               % Probability of the other player playing B
                                ((p_a + alpha - p_b >=0)  *  (p_a+alpha-p_b<=1) * (1/2-(p_a+alpha-p_b)+(p_a+alpha-p_b)^2/2) + ...   % Probability of getting the consumer with p_a superior to p_b but not by 1
                                (p_a + alpha - p_b <0)   *  (-alpha+p_b-p_a<=1) * (1/2-(p_a+alpha-p_b)-(p_a+alpha-p_b)^2/2) + ...
                                (p_a + alpha - p_b <0)   *  (-alpha+p_b-p_a>1)));
    
    full_market_share(ii) = s_1*market_share(ii,1) + (1-s_1)*market_share(ii,2);
    profits(ii) = p_a * full_market_share(ii);
end

% Do a simple plot
figure
yyaxis left
plot(p_grid, sols)
yyaxis right
plot(p_grid, full_market_share)
hold on 
plot(p_grid,profits)
legend('Price', 'Expected market share', 'Profits')
end
