mkdir -p /shared/simrel/lunalimited/tmp

source agg_properties.shsource

ant -buildfile /shared/simrel/lunalimited/org.eclipse.simrel.tools/build.xml -DbuildWorkarea=/shared/simrel/lunalimited -DaggrPropertyFile=/shared/simrel/lunalimited/org.eclipse.simrel.tools/aggr.properties -Drelease=lunalimited -DBRANCH_BUILD=Luna_maintenance_limited -Djava.io.tmpdir=/shared/simrel/lunalimited/tmp -Dequinox.p2.mirros=false runAggregator 2>&1 | tee aggLunaLimitedOutput.txt
