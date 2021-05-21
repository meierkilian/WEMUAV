function comp(simu, real, field)
    realDuration = real.totalTT.Time(end) - real.totalTT.Time(1);
    simuDuration = simu.totalTT.Time(end) - simu.totalTT.Time(1);

    figure(1)
    clf
    hold on
    plot(simu.totalTT.Time - real.totalTT.Time(1), simu.totalTT.(field))
    plot((real.totalTT.Time - real.totalTT.Time(1))./realDuration.*simuDuration, real.totalTT.(field))
    legend("Simu","Real")
end