% % fitness_model2_withzero.m
% % fitness pre model 2. radu s nulou (x = [a1,a2,b0,b1,d])
% function J = fitness_model2_withzero(x, u, y)
%     a1 = x(1); a2 = x(2); b0 = x(3); b1 = x(4); d = round(x(5));
% 
%     % obmedzenie parametrov do fyzikálnych hraníc
%     if d < 0 || abs(a1) > 1 || abs(a2) > 1 || abs(b0) > 10 || abs(b1) > 10
%         J = 1e6; return;
%     end
% 
%     % simulácia modelu
%     yhat = simulate_model2(a1,a2,b0,b1,d,u);
% 
%     % penalizácia nestability a ostrých prechodov
%     if any(isnan(yhat)) || ~isfinite(sum(yhat)) || max(abs(diff(yhat))) > 5
%         J = 1e6; return;
%     end
% 
%     % výpočet chyby
%     e = y(:) - yhat(:);
%     J = mean(e.^2);
% end
