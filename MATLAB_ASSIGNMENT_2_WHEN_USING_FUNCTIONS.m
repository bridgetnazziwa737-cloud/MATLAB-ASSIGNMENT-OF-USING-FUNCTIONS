% AMI GROUP 3 - MATLAB ASSIGNMENT 2 (function-based version)
% Plots AGE and CGPA of students using many chart types.
%
% Function types used in this file:
%   Main function       : AMI_GROUP_3_MATLAB_ASSIGNMENT_2_FUNCTIONS
%   Nested function     : newFigure (shares figCount with the main function)
%   Anonymous functions : the @(x,y) plot handles stored in plotTypes
%   Local functions     : loadStudentData, formatNameAxis, drawHistogram,
%                         drawPareto, drawBoxPlot, drawPie,
%                         drawHorizontalBar, drawNetwork
 
    close all; clc;
 
    % ---------- 1. Import the data ----------
    filePath = 'C:\Users\DELL\Desktop\STUDENTSDATA MATLAB.xlsx';
    studentsData = loadStudentData(filePath);
 
    names = cellstr(studentsData.NAME);   % student names as a cell array
    n     = numel(names);
    x     = (1:n)';                       % x-positions 1..n for the names
 
    figCount = 0;                         % shared with the nested function
 
    % ---------- 2. ANONYMOUS FUNCTIONS: one handle per plot type ----------
    plotTypes = {
        'Line',        @(x,y) plot(x, y, '-o')
        'Scatter',     @(x,y) scatter(x, y, 'filled')
        'Bar',         @(x,y) bar(x, y)
        'Stem',        @(x,y) stem(x, y)
        'Stairs',      @(x,y) stairs(x, y)
        'Error bar',   @(x,y) errorbar(x, y, ones(size(y)))
        'Area',        @(x,y) area(x, y)
        'Logarithmic', @(x,y) semilogx(x, y, '-o')
    };
 
    % Column in the table, and the label used on graphs
    measures = {'AGE', 'Age'; 'CGPA', 'CGPA'};
 
    % ---------- 3. Produce every plot for AGE, then for CGPA ----------
    for m = 1:size(measures, 1)
        y     = studentsData.(measures{m, 1});
        y     = y(:);
        label = measures{m, 2};
 
        % Plots drawn against student names (uses the anonymous functions)
        for k = 1:size(plotTypes, 1)
            newFigure([plotTypes{k, 1} ' plot - ' label]);
            plotFcn = plotTypes{k, 2};
            plotFcn(x, y);
            formatNameAxis(names, 'Student Names', label, ...
                [label ' Against Student Names'], false);
        end
 
        % Plots that need their own layout (local functions)
        newFigure(['Histogram - ' label]);
        drawHistogram(y, label);
 
        newFigure(['Pareto - ' label]);
        drawPareto(y, names, label);
 
        newFigure(['Box plot - ' label]);
        drawBoxPlot(y, label);
 
        newFigure(['Pie chart - ' label]);
        drawPie(y, names, label);
 
        newFigure(['Horizontal bar - ' label]);
        drawHorizontalBar(y, names, label);
 
        newFigure(['Network - ' label]);
        drawNetwork(names, y, label);
    end
 % Nested function
newFigure is written inside the main function, before its final end, so it can use the variable figCount.
    % ---------- NESTED FUNCTION ----------
    % Defined inside the main function so it can read and change figCount.
    function newFigure(figTitle)
    persistent figCount
    if isempty(figCount)
        figCount = 0; % Starts counting from 0 on the first run
    end
    
    figCount = figCount + 1;
    figure('Name', sprintf('Figure %d: %s', figCount, figTitle), ...
           'NumberTitle', 'off');
end
      
    % end of the main function
%3 Anonymous functions
%One-line functions stored in the list plotTypes. They are written inside the main function (a further one, makeLabel, is used inside drawPie).
    plotTypes = {
        'Line',        @(x,y) plot(x, y, '-o')
        'Scatter',     @(x,y) scatter(x, y, 'filled')
        'Bar',         @(x,y) bar(x, y)
        'Stem',        @(x,y) stem(x, y)
        'Stairs',      @(x,y) stairs(x, y)
        'Error bar',   @(x,y) errorbar(x, y, ones(size(y)))
        'Area',        @(x,y) area(x, y)
        'Logarithmic', @(x,y) semilogx(x, y, '-o')
    };
%4 Local functions
These come after the main function and are used only in this file.
%4.1 loadStudentData
function T = loadStudentData(filePath)
% Read the student table, asking the user to browse if the file is missing.
    if ~isfile(filePath)
        [f, p] = uigetfile({'*.xlsx;*.xls;*.csv', 'Spreadsheet files'}, ...
                           'Select the student data file');
        if isequal(f, 0)
            error('No data file was selected.');
        end
        filePath = fullfile(p, f);
    end
 
    T = readtable(filePath);
 
    required = {'NAME', 'AGE', 'CGPA'};
    missing  = required(~ismember(required, T.Properties.VariableNames));
    if ~isempty(missing)
        error('The table is missing column(s): %s', strjoin(missing, ', '));
    end
 
    disp(T);
end
%4.2 formatNameAxis
function formatNameAxis(names, xLab, yLab, figTitle, isHorizontal)
% Put student names on an axis and add labels, title and grid.
    n = numel(names);
    if isHorizontal
        set(gca, 'YTick', 1:n, 'YTickLabel', names);
        xlabel(yLab);
        ylabel(xLab);
    else
        set(gca, 'XTick', 1:n, 'XTickLabel', names);
        xtickangle(45);
        xlabel(xLab);
        ylabel(yLab);
    end
    title(figTitle);
    grid on;
end
%4.3 Histogram
function drawHistogram(y, label)
    histogram(y);
    xlabel(label);
    ylabel('Frequency');
    title(['Histogram of Student ' label]);
    grid on;
end
%4.4 drawPareto
function drawPareto(y, names, label)
% pareto sorts the values from largest to smallest and labels each bar.
    pareto(y, names);
    xlabel('Student Names');
    ylabel(label);
    title(['Pareto Chart of Student ' label]);
    grid on;
end
%4.5 drawBoxPlot
function drawBoxPlot(y, label)
% A box plot summarises the distribution of one variable.
    try
        boxplot(y, 'Labels', {label});     % needs Statistics Toolbox
    catch
        boxchart(y);                       % base MATLAB (R2020a or later)
        set(gca, 'XTick', 1, 'XTickLabel', {label});
    end
    ylabel(label);
    title(['Box Plot of Student ' label]);
    grid on;
end
%4.6 drawPie
function drawPie(y, names, label)
% Pie chart with name and percentage on every slice.
    pct = 100 * y / sum(y);
    makeLabel = @(nm, p) sprintf('%s (%.1f%%)', nm, p);
    sliceLabels = cellfun(makeLabel, names, num2cell(pct), ...
                          'UniformOutput', false);
    pie(y, sliceLabels);
    title([label ' Distribution of Students']);
end
%4.7 drawHorizontalBar
function drawHorizontalBar(y, names, label)
    n = numel(names);
    barh(1:n, y);
    formatNameAxis(names, 'Student Names', label, ...
        [label ' Against Student Names'], true);
end
%4.8 drawNetwork
function drawNetwork(names, y, label)
% Graph linking every student to their Age/CGPA value
% (a network is used because MATLAB has no built-in Sankey plot).
    targets = cellstr(strcat(label, " ", string(y)));
    G = graph(names, targets);
    plot(G);
    title(['Student Names to ' label ' Network']);
end
