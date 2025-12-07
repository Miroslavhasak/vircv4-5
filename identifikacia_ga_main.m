% identifikacia_ga_main.m
% Hlavny skript: spusti GA pre 1. radu s delay, 2. radu bez nuly a 2. radu s nulou
% Vsetky komentare bez diakritiky

clear; close all; clc;

% nazvy suborov
file_id = 'meranie_1.mat';   % identifikacne data
file_test = 'meranie_2.mat'; % testovacie data

% load data
data_id = load(file_id);
data_test = load(file_test);

% ocakavane premenne: tout, u, y
if isfield(data_id,'tout'), t_id = data_id.tout; else error('meranie_1.mat nemá premennu tout'); end
if isfield(data_id,'u'), u_id = data_id.u; else error('meranie_1.mat nemá premennu u'); end
if isfield(data_id,'y'), y_id = data_id.y; else error('meranie_1.mat nemá premennu y'); end

if isfield(data_test,'tout'), t_test = data_test.tout; else error('meranie_2.mat nemá premennu tout'); end
if isfield(data_test,'u'), u_test = data_test.u; else error('meranie_2.mat nemá premennu u'); end
if isfield(data_test,'y'), y_test = data_test.y; else error('meranie_2.mat nemá premennu y'); end

% konvertuj na stlpce
t_id = t_id(:); u_id = u_id(:); y_id = y_id(:);
t_test = t_test(:); u_test = u_test(:); y_test = y_test(:);

% urci Ts z tout (pouzije median diff)
Ts = median(diff(t_id));
Ts_test = median(diff(t_test));
if isempty(Ts) || Ts <= 0, Ts = 0.05; end
if isempty(Ts_test) || Ts_test <= 0, Ts_test = Ts; end

fprintf('Vzorkovanie Ts = %.5f s\n', Ts);
fprintf('Pocty vzoriek: identifikacna = %d, test = %d\n', numel(u_id), numel(u_test));

% GA nastavenia spolocne
options = optimoptions('ga', ...
    'PopulationSize', 350, ...
    'MaxGenerations', 500, ...
    'Display', 'iter', ...
    'UseParallel', true);

%% model 1: 1. radu s delay (parametre: K, T, d_samples)
lb1 = [0, 1e-3, 0];
ub1 = [1000, 200, 50];
nvars1 = 3;
fprintf('\nSpustam GA pre model 1. radu s delay...\n');
fitness1 = @(x) fitness_model1(x, u_id, y_id, Ts);
[xbest1, fval1] = ga(fitness1, nvars1, [], [], [], [], lb1, ub1, [], options);
K1 = xbest1(1); T1 = xbest1(2); d1 = round(xbest1(3));
fprintf('Model1: K=%.4f, T=%.4f, d(samples)=%d, fval=%.6g\n', K1,T1,d1,fval1);

% simulacia
yhat_id_m1 = simulate_model1(K1, T1, d1, u_id, Ts);
yhat_test_m1 = simulate_model1(K1, T1, d1, u_test, Ts_test);

%% pridane
% Vytvorenie jemnej casovej osi pre plynule vykreslenie
Ts_fine = Ts / 10; % 10x jemnejsie vzorkovanie (napr. 0.005s)

% Spojity model G(s)
% Uistite sa, ze mate premenne K1, T1 a d1 uz vypocitane z GA
Td1 = d1 * Ts; % Disketne oneskorenie prevedene na sekundy

% Model 1. radu v spojitom case (s dopravnym oneskorenim)
sys_s1 = tf(K1, [T1 1], 'InputDelay', Td1);

% SIMULACIA NA JEMNOM VZORKOVANI (IDENTIFIKACNA SADA)
time_fine_id = (0:Ts_fine:t_id(end))';
u_fine_id = interp1(t_id, u_id, time_fine_id, 'previous', 'extrap'); % Vstup treba interpolovat pre jemnu osu

yhat_fine_id_m1 = lsim(sys_s1, u_fine_id, time_fine_id);

% SIMULACIA NA JEMNOM VZORKOVANI (TESTOVACIA SADA)
time_fine_test = (0:Ts_fine:t_test(end))';
u_fine_test = interp1(t_test, u_test, time_fine_test, 'previous', 'extrap'); % Vstup treba interpolovat

yhat_fine_test_m1 = lsim(sys_s1, u_fine_test, time_fine_test);

%% potialto pridane

metrics_id_m1 = compute_metrics(y_id, yhat_id_m1);
metrics_test_m1 = compute_metrics(y_test, yhat_test_m1);

%% model 2: 2. radu bez nuly (diskretna forma) (parametre: a1,a2,b0,d)
% lb2a = [-10, -10, -500, 0];
% ub2a = [10, 10, 500, 50];
lb2a = [-3, -3, -100, 0];
ub2a = [3, 3, 100, 10];
nvars2a = 4;
fprintf('\nSpustam GA pre model 2. radu BEZ nuly (b1=0)...\n');
fitness2a = @(x) fitness_model2_nozero(x, u_id, y_id);
[xbest2a, fval2a] = ga(fitness2a, nvars2a, [], [], [], [], lb2a, ub2a, [], options);
a1_2a = xbest2a(1); a2_2a = xbest2a(2); b0_2a = xbest2a(3); d2a = round(xbest2a(4));
fprintf('Model2 nozero: a1=%.4f, a2=%.4f, b0=%.4f, d=%d, fval=%.6g\n', a1_2a,a2_2a,b0_2a,d2a,fval2a);

yhat_id_m2a = simulate_model2(a1_2a,a2_2a,b0_2a,0,d2a,u_id);
yhat_test_m2a = simulate_model2(a1_2a,a2_2a,b0_2a,0,d2a,u_test);

metrics_id_m2a = compute_metrics(y_id, yhat_id_m2a);
metrics_test_m2a = compute_metrics(y_test, yhat_test_m2a);

% %% model 2: 2. radu S NULOU (parametre: a1,a2,b0,b1,d)
% lb2b = [-10, -10, -500, -500, 0];
% ub2b = [10, 10, 500, 500, 50];
% nvars2b = 5;
% fprintf('\nSpustam GA pre model 2. radu S NULOU (b1 free)...\n');
% fitness2b = @(x) fitness_model2_withzero(x, u_id, y_id);
% [xbest2b, fval2b] = ga(fitness2b, nvars2b, [], [], [], [], lb2b, ub2b, [], options);
% a1_2b = xbest2b(1); a2_2b = xbest2b(2); b0_2b = xbest2b(3); b1_2b = xbest2b(4); d2b = round(xbest2b(5));
% fprintf('Model2 withzero: a1=%.4f, a2=%.4f, b0=%.4f, b1=%.4f, d=%d, fval=%.6g\n', a1_2b,a2_2b,b0_2b,b1_2b,d2b,fval2b);
% 
% yhat_id_m2b = simulate_model2(a1_2b,a2_2b,b0_2b,b1_2b,d2b,u_id);
% yhat_test_m2b = simulate_model2(a1_2b,a2_2b,b0_2b,b1_2b,d2b,u_test);
% 
% metrics_id_m2b = compute_metrics(y_id, yhat_id_m2b);
% metrics_test_m2b = compute_metrics(y_test, yhat_test_m2b);

%% uloz vysledky
results.model1.K = K1; results.model1.T = T1; results.model1.d = d1; results.model1.fval = fval1;
results.model1.metrics_id = metrics_id_m1; results.model1.metrics_test = metrics_test_m1;

results.model2_nozero.a1 = a1_2a; results.model2_nozero.a2 = a2_2a; results.model2_nozero.b0 = b0_2a; results.model2_nozero.d = d2a; results.model2_nozero.fval = fval2a;
results.model2_nozero.metrics_id = metrics_id_m2a; results.model2_nozero.metrics_test = metrics_test_m2a;

% results.model2_withzero.a1 = a1_2b; results.model2_withzero.a2 = a2_2b; results.model2_withzero.b0 = b0_2b; results.model2_withzero.b1 = b1_2b; results.model2_withzero.d = d2b; results.model2_withzero.fval = fval2b;
% results.model2_withzero.metrics_id = metrics_id_m2b; results.model2_withzero.metrics_test = metrics_test_m2b;

save('results.mat','results');

% %% vykreslenie - Upravená verzia
% time_id = t_id;
% time_test = t_test;
% 
% % --- 1. GRAF: IDENTIFIKAČNÁ SADA ---
% figure('Name','1. Identifikacia: Porovnanie modelov na ID sade');
% 
% % Vykresliť všetky krivky do jedného podgrafu (subplot 1,1,1)
% % Najprv vykreslíme namerané dáta, potom modely
% plot(time_id, y_id, 'k', 'LineWidth', 1.5); % Merané dáta (čierna, hrubá čiara)
% hold on;
% plot(time_id, yhat_id_m1, 'b--', 'LineWidth', 1.2); % Model 1 (modrá, prerušovaná)
% plot(time_id, yhat_id_m2a, 'r-.', 'LineWidth', 1.2); % Model 2 bez nuly (červená, bodkovaná)
% 
% % Ak by ste chceli pridať aj model s nulou (yhat_id_m2b), odkomentujte nasledujúci riadok:
% % plot(time_id, yhat_id_m2b, 'g:', 'LineWidth', 1.2); 
% 
% title('Identifikacna sada: Porovnanie nameranych otacok (y) a modelov');
% xlabel('Cas [s]');
% ylabel('Otacky / Napatie [V]');
% legend('y merane', 'Model 1. radu (K, T, d)', 'Model 2. radu (bez nuly)', 'Location', 'best');
% grid on;
% hold off;
% 
% 
% % --- 2. GRAF: TESTOVACIA SADA ---
% figure('Name','2. Testovanie: Porovnanie modelov na TEST sade');
% 
% % Vykresliť všetky krivky do jedného podgrafu
% plot(time_test, y_test, 'k', 'LineWidth', 1.5); % Merané dáta (čierna, hrubá čiara)
% hold on;
% plot(time_test, yhat_test_m1, 'b--', 'LineWidth', 1.2); % Model 1
% plot(time_test, yhat_test_m2a, 'r-.', 'LineWidth', 1.2); % Model 2 bez nuly
% 
% % Ak by ste chceli pridať aj model s nulou (yhat_test_m2b), odkomentujte nasledujúci riadok:
% % plot(time_test, yhat_test_m2b, 'g:', 'LineWidth', 1.2);
% 
% title('Testovacia sada: Porovnanie nameranych otacok (y) a modelov');
% xlabel('Cas [s]');
% ylabel('Otacky / Napatie [V]');
% legend('y merane', 'Model 1. radu (K, T, d)', 'Model 2. radu (bez nuly)', 'Location', 'best');
% grid on;
% hold off;

%% vykreslenie
time_id = t_id;
time_test = t_test;

figure('Name','Identifikacia: identifikacna sada');
subplot(2,1,1)
plot(time_id,y_id,'-'); hold on; plot(time_id,yhat_id_m1,'--'); legend('y merane','model1'); xlabel('cas [s]'); ylabel('y'); title('Model 1. radu');

subplot(2,1,2)
plot(time_id,y_id,'-'); hold on; plot(time_id,yhat_id_m2a,'--'); legend('y merane','model2 bez nuly'); xlabel('cas [s]'); ylabel('y'); title('Model 2. radu bez nuly');

% subplot(3,1,3)
% plot(time_id,y_id,'-'); hold on; plot(time_id,yhat_id_m2b,'--'); legend('y merane','model2 s nulou'); xlabel('cas [s]'); ylabel('y'); title('Model 2. radu s nulou');

figure('Name','Testovanie: testovacia sada');
subplot(2,1,1)
plot(time_test,y_test,'-'); hold on; plot(time_test,yhat_test_m1,'--'); legend('y merane','model1'); xlabel('cas [s]'); ylabel('y'); title('Model 1. radu');

subplot(2,1,2)
plot(time_test,y_test,'-'); hold on; plot(time_test,yhat_test_m2a,'--'); legend('y merane','model2 bez nuly'); xlabel('cas [s]'); ylabel('y'); title('Model 2. radu bez nuly');

% subplot(3,1,3)
% plot(time_test,y_test,'-'); hold on; plot(time_test,yhat_test_m2b,'--'); legend('y merane','model2 s nulou'); xlabel('cas [s]'); ylabel('y'); title('Model 2. radu s nulou');

%% vypis metriksov
disp('--- METRIKY (identifikacna) ---');
disp(results.model1.metrics_id);
disp(results.model2_nozero.metrics_id);
% disp(results.model2_withzero.metrics_id);

disp('--- METRIKY (test) ---');
disp(results.model1.metrics_test);
disp(results.model2_nozero.metrics_test);
% disp(results.model2_withzero.metrics_test);

fprintf('Hotovo. Results ulozene v results.mat\n');
