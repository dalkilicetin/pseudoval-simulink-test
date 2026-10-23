%% run_all - pseudoval Simulink denemesi (GitHub Actions)
%%
%% moduller.txt'teki her modul icin:
%%   1) <M>_selftest                  (Simulink'siz, _step.m)
%%   2) <M>_model.mdl                 Level-2 MATLAB S-Function, sim()
%%   3) build_<M> + <M>_model_mex.mdl C MEX S-Function, sim()
%% Her sim, ref_in.csv girdileriyle kosulur; cikislar pseudoval
%% yorumlayicisinin ref_out.csv'siyle cevrim cevrim karsilastirilir.
%% Hata olursa raporun TAMAMI yazilir.

kok = pwd;
mods = strtrim(splitlines(fileread(fullfile(kok, 'moduller.txt'))));
mods = mods(~cellfun(@isempty, mods));
sonuc = {};
for i = 1:numel(mods)
    M = mods{i};
    cd(fullfile(kok, M));
    sonuc(end+1, :) = {M, 'selftest', dene(@() evalc([M '_selftest']))}; %#ok<AGROW>
    close all force;
    sonuc(end+1, :) = {M, 'MATLAB S-Function', simule(M, [M '_model'])}; %#ok<AGROW>
    mx = dene(@() evalc(['build_' M]));
    if isempty(mx)
        sonuc(end+1, :) = {M, 'C MEX S-Function', simule(M, [M '_model_mex'])}; %#ok<AGROW>
    else
        sonuc(end+1, :) = {M, 'C MEX derleme', mx}; %#ok<AGROW>
    end
    cd(kok);
end

fprintf('\n================ OZET ================\n');
nf = 0;
for i = 1:size(sonuc, 1)
    if isempty(sonuc{i, 3})
        fprintf('PASS  %-24s %s\n', sonuc{i, 1}, sonuc{i, 2});
    else
        nf = nf + 1;
        fprintf('FAIL  %-24s %s\n%s\n\n', sonuc{i, 1}, sonuc{i, 2}, sonuc{i, 3});
    end
end
fprintf('%d deneme, %d FAIL\n', size(sonuc, 1), nf);
if nf > 0
    error('pseudoval:simulink', '%d deneme basarisiz', nf);
end

%% ------------------------------------------------------------------
function msg = dene(f)
msg = '';
try
    f();
catch ME
    msg = getReport(ME, 'extended', 'hyperlinks', 'off');
end
end

function msg = simule(M, mdl)
msg = '';
try
    load_system([mdl '.mdl']);
    R = readmatrix('ref_in.csv');
    E = readmatrix('ref_out.csv');
    N = size(R, 1);
    dt = str2double(get_param(mdl, 'FixedStep'));
    args = {'StopTime', num2str((N - 1) * dt, 17), ...
            'SaveOutput', 'on', 'OutputSaveName', 'yout', ...
            'SaveFormat', 'Array', 'SaveTime', 'on', ...
            'ReturnWorkspaceOutputs', 'on'};
    if size(R, 2) > 1
        assignin('base', 'pv_girdi', R);
        args = [args, {'LoadExternalInput', 'on', 'ExternalInput', 'pv_girdi'}];
    end
    so = sim(mdl, args{:});
    Y = so.get('yout');
    if isempty(E)
        fprintf('%s: cikis yok, sim tamam\n', mdl);
    elseif size(Y, 1) < N || size(Y, 2) ~= size(E, 2)
        msg = sprintf('cikis boyutu %dx%d, beklenen %dx%d', size(Y, 1), ...
                      size(Y, 2), N, size(E, 2));
    else
        Y = Y(1:N, :);
        ayni = (Y == E) | (isnan(Y) & isnan(E)) | ...
               abs(Y - E) <= 1e-9 * max(1, abs(E));
        [r, c] = find(~ayni, 1);
        if ~isempty(r)
            msg = sprintf(['cevrim %d (t=%g) cikis %d: Simulink=%.17g, ' ...
                           'yorumlayici=%.17g'], r - 1, R(r, 1), c, ...
                          Y(r, c), E(r, c));
        else
            fprintf('%s: %d cevrim x %d cikis yorumlayiciyla AYNI\n', ...
                    mdl, N, size(E, 2));
        end
    end
catch ME
    msg = getReport(ME, 'extended', 'hyperlinks', 'off');
end
try
    close_system(mdl, 0);
catch
end
end
