function redData = removeDescentPhase(data)
%     if data.Properties.CustomProperties.FlightName ~= "FLY168__20210503_143909__Vertical3ms"
%         error("Unsupported flight !!!")
%     end
    
    startTime = [
        datetime(2021,05,03,14,39,13)
        datetime(2021,05,03,14,39,30)
        datetime(2021,05,03,14,39,43)
        ];
    
    endTime = [
        datetime(2021,05,03,14,39,18)
        datetime(2021,05,03,14,39,33)
        datetime(2021,05,03,14,39,49)
        ]; 
    
    redData = [];
    for i = 1:length(startTime)
        tmp = data(timerange(startTime(i),endTime(i)),:);
        redData = [redData; tmp];
    end
end