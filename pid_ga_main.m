% pid_ga_main.m
clear; close all; clc;

% --- Parametre najlepšieho identifikovaného modelu (Z Ulohy 4) ---
% Tieto hodnoty musíte dosadiť ručne z výsledku identifikacie.
% Predpokladame Model 2. radu bez nuly:
% a1 = -0.2181;   % Z výsledkov GA Modelu 2. rádu
% a2 = -0.6981;    % Z výsledkov GA Modelu 2. rádu
% b0 = 0.0843;    % Z výsledkov GA Modelu 2. rádu

a1=0.1387, a2=-0.7435, b0=0.4146;
b1 = 0;      % Bez nuly
d = 2;       % Oneskorenie v pocte vzoriek

Ts = 0.05;

% --- Nastavenie GA ---
options = optimoptions('ga', ...
    'PopulationSize', 350, ...
    'MaxGenerations', 500, ...
    'Display', 'iter', ...
    'MutationFcn', @mutationadaptfeasible, ... % Odporucane pre obmedzenia
    'UseParallel', true);

% Hladane parametre: [Kp, Ti, Td]
% Hranice PID (zadane 0-10, Ti a Td nemozu byt nulove, inak by to bolo nekonecne)
% Ti: Musí byť > 0, takže dolnú hranicu pre Ti nastavíme na veľmi malé číslo.
% lb_pid = [0, 1e-4, 0]; 
% ub_pid = [10, 10, 10];

lb_pid = [0, 0.1, 0];
ub_pid = [10, 5, 5];
nvars_pid = 3;

fprintf('\nSpustam GA pre optimalizaciu PID regulatora...\n');

% Kritická lambda pre penalizáciu Delta u (zmente podľa potreby)
lambda_delta_u = 0.1; 

% Spustenie GA
fitness_pid = @(x) fitness_pid(x, a1, a2, b0, b1, d, Ts, lambda_delta_u);
[xbest_pid, fval_pid] = ga(fitness_pid, nvars_pid, [], [], [], [], lb_pid, ub_pid, [], options);

Kp_opt = xbest_pid(1); Ti_opt = xbest_pid(2); Td_opt = xbest_pid(3);

fprintf('Optimalne PID parametre: Kp=%.4f, Ti=%.4f, Td=%.4f\n', Kp_opt, Ti_opt, Td_opt);
fprintf('Dosiahnuta kriterialna funkcia (J)=%.6g\n', fval_pid);

% --- Simulacia finalneho modelu pre vykreslenie ---
[t, w, y, u] = simulate_pid_closed_loop(Kp_opt, Ti_opt, Td_opt, a1, a2, b0, b1, d, Ts);

figure('Name','Optimalna odozva PID regulacie');
subplot(2,1,1);
plot(t, w, 'k--', 'LineWidth', 1.5);
hold on;
plot(t, y, 'b', 'LineWidth', 1.5);
title('Odozva regulovanej veliciny y');
xlabel('Cas [s]');
ylabel('y, w [V]');
legend('Ziadana hodnota w', 'Regulovana velicina y', 'Location', 'best');
grid on;

subplot(2,1,2);
plot(t, u, 'r', 'LineWidth', 1.5);
title('Akcny zasah u');
xlabel('Cas [s]');
ylabel('u [V]');
ylim([0 10]); % Zobrazenie limitov akcneho zasahu
grid on;