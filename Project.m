%% Liam Cauquil (1394106)
% Prof Chen && TA Diaz
% Final Project - ECG Data Manipulation
% Due 5 May 2016



%% Main Function
function [] = Project()
% loading function and setting arrays for data and times
load('ProjectMay5th.mat');
% get times and data points
array = PT1n(1:2000);
arrayb = PT2n(1:2000); 
tmPT1 = (1:2000)/360;
tmPT2 = (1:2000)/250;
time = (1:1803)/360;
time2 = (1:1816)/250;

% plots data unfiltered
figure('Name','UNFILTERED DATA','NumberTitle','off')
subplot(211), plot(tmPT1, array,'Color', [0 1 0]);
    set(gca, 'Color',[0,0,0]);
    grid on;
    set(gca, 'XColor','g')
    set(gca, 'YColor','g');
    title('Patient 1 -Unifiltered-');
    xlabel('Time (sec)');
    ylabel('Frequency (Hz)');
subplot(212), plot(tmPT2, arrayb, 'Color', [0 1 0]);
    set(gca, 'Color',[0,0,0]);
    grid on;
    set(gca, 'XColor','g')
    set(gca, 'YColor','g');
    title('Patient 2 -Unfiltered-');
    xlabel('Time (sec)');
    ylabel('Frequency (Hz)');

% Makes Filters Array with personal designed Filter and a sgolayfilt, then plots them
Filtered1= filtfilt(thatFilterDough(360), array);
Filtered2= filtfilt(thatFilterDough(250), arrayb);
P1 = sgolayfilt(Filtered1, 2, 21);
P2 = sgolayfilt(Filtered2, 2, 21);

% Plots data with only R plots and avg pulse rate 
figure('Name','Filtered Data w/ Rplots & AVG Pulse Rate','NumberTitle','off')
plotFilt(P1, 211, 50, 'Patient 1 -Filtered-', tmPT1, time);
text(3, -30, ['AVG: ' num2str(avgPulseRate(P1, 50, 360)) ' BPM'], 'Color', [1 0 0], 'FontWeight', 'bold');
plotFilt(P2, 212, 10, 'Patient 2 -Filtered-', tmPT2, time2);
text(4, -120, ['AVG: ' num2str(avgPulseRate(P2, 10, 250)) ' BPM'], 'Color', [1 0 0], 'FontWeight', 'bold');

% Plots data with only Heart Rate Variation
figure('Name','Heart Rate Variation','NumberTitle','off');
plotFilt(P1, 211, 50, 'Patient 1 -Heart Rate Variation-', tmPT1, time);
plotRRintervals(P1, 50, 360);
plotFilt(P2, 212, 10, 'Patient 2 -Heart Rate Variation-', tmPT2, time2);
plotRRintervals(P2, 10, 250);
end

%% Plots over a graph the RR ints showing dt above and dBPM below
function [] = plotRRintervals(inputArray, LUB, sampleFreq)
    rs = findRs(inputArray, LUB);
    def = find(~isnan(rs));
    stay = def;
    xLengths = diff(def);
    yVals = inputArray(def);
    def = def/sampleFreq;

    hold on;
    for i = 1:length(xLengths);
        plot((linspace(def(i),def(i+1))), linspace(yVals(i), yVals(i)), 'Color', [1 1 0]);
        tm = def(i+1)-def(i);
        eg = sprintf('%.3f sec', tm);
        t(i) = text(def(i)+0.2, yVals(i)+7.5, eg, 'Color', [1 1 0]);
        BPM = inputArray(stay(i));
        StrBPM = sprintf('%.1f BPM', BPM);
        t2(i) = text(def(i)+0.2, yVals(i)-10, StrBPM, 'Color', [1 1 0]);
        hold on;
    end
end

%% Plots a combination of filtered data and R plots
function [] = plotFilt (filtArray, subNum, LUB, strTitle, time, tm)
    subplot(subNum), plot(time, filtArray, 'Color',[0,1,0]);
    xlabel('Time (sec)');
    ylabel('Frequency (Hz)');
    hold on;
    plot(tm, findRs(filtArray, LUB), 'ro');
    set(gca, 'Color',[0,0,0]);
    grid on;
    set(gca, 'XColor','g')
    set(gca, 'YColor','g');
    title(strTitle);
end

%% finds average pulse rate when given data, Lower Upper Bound and Sample Frequency
function [avgPulseRate] = avgPulseRate (array, LUB, sampleFrequency)
    rs = findRs(array, LUB);
    def = find(~isnan(rs));
    dx = diff(def);
    tehMeanRs = mean(dx);
    avgPulseRate = 60*sampleFrequency/tehMeanRs;
end

%% Finds change in x vals for RR ints
function [xLengths] = dxRR (array, LUB)
    rs = findRs(array, LUB);
    def = find(~isnan(rs));
    xLengths = diff(def);
end

%% Filters Data
function [d] = thatFilterDough(SampleRate)
    d = designfilt('bandstopiir','FilterOrder',2, ...
               'HalfPowerFrequency1',59,'HalfPowerFrequency2',61, ...
               'DesignMethod','butter','SampleRate',SampleRate);
    
end


%% Finds xvals for R peaks
function [points] = findRs(x,a)
    points =0;
    for i = 2:1:length(x)-1
        if (x(i) > a &&x(i)>x(i+1) && x(i)>x(i-1))
            points(i) = x(i);
        end
    end
    points(points==0) = nan;
end


