function VisualizeArduinoOutput()
    clearvars(); close all; clc(); drawnow(); delete(instrfind());
    
    % When rendering, rotate each sensor by this amount to match physical orientation
    ROTATE_OFFSET = 0;      % Arduino USB pointing right
    %ROTATE_OFFSET = 90;     % Arduino USB pointing up
    %ROTATE_OFFSET = 180;    % Arduino USB pointing left
    %ROTATE_OFFSET = 270;    % Arduino USB pointing down
    
    LOW_RANGE_THRESHOLD = 20;
    MEDIUM_RANGE_THRESHOLD = 1200;
    HIGH_RANGE_THRESHOLD = 1500;
    
    SERIAL_COM_PORT = 'COM8';
    SERIAL_BAUD_RATE = 115200;
    
    r = [46, 46, 46, 46, 46, 46, 46, 46];   % mm
    theta = [180, 130, 90, 50, 0, -50, -90, -130] + ROTATE_OFFSET;
    id = {'0', '1', '2', '3', '4', '5', '6', '7'};
    nSensors = numel(r);
    
    % pointing vectors of sensors, relative to center of shield
    v = zeros(2, nSensors);
    
    % Sensor Positions (in cartesian)
    posSensors = zeros(2, nSensors);
    
    for i=1:nSensors
        v(1,i) = r(i)*cosd(theta(i));
        v(2,i) = r(i)*sind(theta(i));
        
        posSensors(:,i) = v(:,i);
        v(:,i) = v(:,i) ./ norm(v(:,i), 2);
    end
    
    hFig = figure();
    axFig = axes('Parent', hFig);
    
    props = struct( ...
        'LowThreshold', LOW_RANGE_THRESHOLD, ...
        'MedThreshold', MEDIUM_RANGE_THRESHOLD, ...
        'HighThreshold', HIGH_RANGE_THRESHOLD, ...
        'SensorRadius', {r}, ...
        'SensorAngles', {theta}, ...
        'SensorIDs', {id}, ...
        'nSensors', nSensors, ...
        'SensorVectors', {v}, ...
        'SensorPositions', {posSensors}, ...
        'OutputAxis', axFig);
    
    %
    % Connect to serial device
    %
%     serialPort = serial(SERIAL_COM_PORT, 'BaudRate', SERIAL_BAUD_RATE, ...
%         'DataBits', 8, 'Parity', 'none', 'StopBits', 1, ...
%         'BytesAvailableFcnCount', 1, ...
%         'BytesAvailableFcnMode', 'terminator', ...
%         'Terminator', '#', ...
%         'BytesAvailableFcn', {@SerialCallback, props}, ...
%         'TimerPeriod', 0.01

    fprintf('Serial range demo running.  Press Ctrl+C in the command window to quit.\n');
    
    serialPort = serial(SERIAL_COM_PORT, 'BaudRate', SERIAL_BAUD_RATE, ...
        'DataBits', 8, 'Parity', 'none', 'StopBits', 1);
    fopen(serialPort);
    
    allBytes = char([]);
    while(true)
       allBytes = [allBytes char(fread(serialPort, 1)')];
       
       idxDollar = find(allBytes=='$', 1, 'first');
        if (isempty(idxDollar)); continue; end;
        allBytes = allBytes(idxDollar:end);
        idxPound = find(allBytes=='#', 1, 'first');
        if (isempty(idxPound)); continue; end;
        
        str = allBytes(1:idxPound);
        allBytes = allBytes((idxPound+1):end);
        
        RenderFromMessage(str, props);
        
       % pause(0.05);
    end
    
    pause(10);
    
    fclose(serialPort);
    fprintf('done\n');
end



function RenderFromMessage(str, props)
   
    axFig = props.OutputAxis;
    
    cla(axFig);
    hold(axFig, 'on');
    axis(axFig, 'equal');
    xlim(axFig, [-props.HighThreshold, props.HighThreshold]);
    ylim(axFig, [-props.HighThreshold, props.HighThreshold]);
    title(axFig, 'Ranges (mm)');
    
    %
    % Parse string into observations
    %
    ranges = sscanf(str, '$%u,%u,%u,%u,%u,%u,%u,%u#');
    if (numel(ranges) ~= props.nSensors); return; end;
    
    %
    % Draw Range Measurements
    %
    for i=1:props.nSensors
        
        if (ranges(i) == 65535)
            continue;
        end
        
        posRange = props.SensorPositions(:,i) + props.SensorVectors(:,i)*ranges(i);
        ls = '-';
        c = 'k';
        
        if ((ranges(i) < props.LowThreshold) || ((ranges(i) > props.MedThreshold) && (ranges(i) < props.HighThreshold)))
            ls = '--';
            c = 'b';
        elseif (ranges(i) > props.HighThreshold)
            ls = ':';
            c = 'r';
        end
        
        line([props.SensorPositions(1,i) posRange(1)], [props.SensorPositions(2,i) posRange(2)], 'Parent', axFig, 'Color', c, 'LineStyle', ls);
        plot(axFig, posRange(1), posRange(2), 'bo', 'MarkerFaceColor', 'b');
        posText = props.SensorPositions(:,i) + props.SensorVectors(:,i).*(ranges(i)+250);
        hText = text(axFig, posText(1), posText(2), sprintf('%s: %4u', props.SensorIDs{i}, ranges(i)));
        set(hText, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
    end
    
    drawnow();
end
