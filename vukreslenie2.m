figure;

plot(t_test, y_test, "LineWidth", 1.5); hold on;
plot(t_test, yhat_test_m1, "LineWidth", 1.3);
plot(t_test, yhat_test_m2a, "LineWidth", 1.3);
plot(t_test, yhat_test_m2b, "LineWidth", 1.3);

legend("y meranie", "model 1. radu", "model 2. radu", "model 2. radu s nulou");
xlabel("cas [s]");
ylabel("otacky [V]");
title("Porovnanie modelov na testovacej sade");
grid on;
