#!/usr/bin/env bash

#*******************************************************************************
# Copyright (c) 2019 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html,
# or the MIT License which is available at https://opensource.org/licenses/MIT.
# SPDX-License-Identifier: EPL-2.0 OR MIT
#*******************************************************************************

#copy files into eclipse/dropins/plugins
export DEST=${1:-eclipse/dropins/plugins}

#platform

cp /home/data/httpd/download.eclipse.org/releases/neon/201609281000/plugins/org.eclipse.jdt.doc.isv_3.12.1.v20160825-1158.jar $DEST/
cp /home/data/httpd/download.eclipse.org/releases/neon/201609281000/plugins/org.eclipse.jdt.doc.user_3.12.1.v20160727-2009.jar $DEST/
cp /home/data/httpd/download.eclipse.org/releases/neon/201609281000/plugins/org.eclipse.pde.doc.user_3.12.1.v20160825-1158.jar $DEST/
cp /home/data/httpd/download.eclipse.org/releases/neon/201609281000/plugins/org.eclipse.platform.doc.isv_4.6.1.v20160829-1312.jar $DEST/
cp /home/data/httpd/download.eclipse.org/releases/neon/201609281000/plugins/org.eclipse.platform.doc.user_4.6.1.v20160727-2009.jar $DEST/

#egit

cp /home/data/httpd/download.eclipse.org/egit/updates-4.4/plugins/org.eclipse.egit.doc_4.4.0.201606070830-r.jar $DEST/

#sirius

cp /home/data/httpd/download.eclipse.org/sirius/updates/releases/4.0.1/org.eclipse.sirius.doc.properties-4.0.1-SNAPSHOT.jar $DEST/
cp /home/data/httpd/download.eclipse.org/sirius/updates/releases/4.0.1/neon/plugins/org.eclipse.sirius.doc_4.0.1.201608261223.jar $DEST/

#pdt

cp /home/data/httpd/download.eclipse.org/tools/pdt/updates/4.1/plugins/org.eclipse.php.help_4.1.0.201609140517.jar $DEST/

#scout

cp /home/data/httpd/download.eclipse.org/scout/releases/6.0/6.0.100/RC4/plugins/org.eclipse.scout.sdk.s2e.doc_6.0.100.RC4.jar $DEST/

#gef

cp /home/data/httpd/download.eclipse.org/tools/gef/updates/legacy/integration/4.0.0_gef-master_1952/plugins/org.eclipse.draw2d.doc.isv_3.10.100.201606061308.jar $DEST/
cp /home/data/httpd/download.eclipse.org/tools/gef/updates/legacy/integration/4.0.0_gef-master_1952/plugins/org.eclipse.gef.doc.isv_3.11.0.201606061308.jar $DEST/
cp /home/data/httpd/download.eclipse.org/tools/gef/updates/legacy/integration/4.0.0_gef-master_1952/plugins/org.eclipse.zest.core_1.5.300.201606061308.jar $DEST/

cp /home/data/httpd/download.eclipse.org/tools/gef/gef4/updates/milestones/4.0.0RC4_gef4-master_3401/plugins/org.eclipse.gef4.cloudio.doc.user_1.0.0.201606082015.jar $DEST/
cp /home/data/httpd/download.eclipse.org/tools/gef/gef4/updates/milestones/4.0.0RC4_gef4-master_3401/plugins/org.eclipse.gef4.cloudio.doc_1.0.0.201606082015.jar $DEST/
cp /home/data/httpd/download.eclipse.org/tools/gef/gef4/updates/milestones/4.0.0RC4_gef4-master_3401/plugins/org.eclipse.gef4.common.doc_1.0.0.201606082015.jar $DEST/
cp /home/data/httpd/download.eclipse.org/tools/gef/gef4/updates/milestones/4.0.0RC4_gef4-master_3401/plugins/org.eclipse.gef4.dot.doc.user_1.0.0.201606082015.jar $DEST/
cp /home/data/httpd/download.eclipse.org/tools/gef/gef4/updates/milestones/4.0.0RC4_gef4-master_3401/plugins/org.eclipse.gef4.dot.doc_1.0.0.201606082015.jar $DEST/
cp /home/data/httpd/download.eclipse.org/tools/gef/gef4/updates/milestones/4.0.0RC4_gef4-master_3401/plugins/org.eclipse.gef4.fx.doc_1.0.0.201606082015.jar $DEST/
cp /home/data/httpd/download.eclipse.org/tools/gef/gef4/updates/milestones/4.0.0RC4_gef4-master_3401/plugins/org.eclipse.gef4.geometry.doc_1.0.0.201606082015.jar $DEST/
cp /home/data/httpd/download.eclipse.org/tools/gef/gef4/updates/milestones/4.0.0RC4_gef4-master_3401/plugins/org.eclipse.gef4.graph.doc_1.0.0.201606082015.jar $DEST/
cp /home/data/httpd/download.eclipse.org/tools/gef/gef4/updates/milestones/4.0.0RC4_gef4-master_3401/plugins/org.eclipse.gef4.layout.doc_1.0.0.201606082015.jar $DEST/
cp /home/data/httpd/download.eclipse.org/tools/gef/gef4/updates/milestones/4.0.0RC4_gef4-master_3401/plugins/org.eclipse.gef4.mvc.doc_1.0.0.201606082015.jar $DEST/
cp /home/data/httpd/download.eclipse.org/tools/gef/gef4/updates/milestones/4.0.0RC4_gef4-master_3401/plugins/org.eclipse.gef4.zest.doc_1.0.0.201606082015.jar $DEST/

#stardust

#cp /home/data/httpd/download.eclipse.org/stardust/milestones/neon/4.0.1/plugins/org.eclipse.stardust.docs.analyst_4.0.1.v20160914-0420.jar $DEST/
#cp /home/data/httpd/download.eclipse.org/stardust/milestones/neon/4.0.1/plugins/org.eclipse.stardust.docs.camel_4.0.1.v20160914-0420.jar $DEST/
#cp /home/data/httpd/download.eclipse.org/stardust/milestones/neon/4.0.1/plugins/org.eclipse.stardust.docs.deployment_4.0.1.v20160914-0420.jar $DEST/
#cp /home/data/httpd/download.eclipse.org/stardust/milestones/neon/4.0.1/plugins/org.eclipse.stardust.docs.dev_4.0.1.v20160914-0420.jar $DEST/
#cp /home/data/httpd/download.eclipse.org/stardust/milestones/neon/4.0.1/plugins/org.eclipse.stardust.docs.dms_4.0.1.v20160914-0420.jar $DEST/
#cp /home/data/httpd/download.eclipse.org/stardust/milestones/neon/4.0.1/plugins/org.eclipse.stardust.docs.enduser_4.0.1.v20160914-0420.jar $DEST/
#cp /home/data/httpd/download.eclipse.org/stardust/milestones/neon/4.0.1/plugins/org.eclipse.stardust.docs.installation_4.0.1.v20160914-0420.jar $DEST/
#cp /home/data/httpd/download.eclipse.org/stardust/milestones/neon/4.0.1/plugins/org.eclipse.stardust.docs.misc_4.0.1.v20160914-0420.jar $DEST/
#cp /home/data/httpd/download.eclipse.org/stardust/milestones/neon/4.0.1/plugins/org.eclipse.stardust.docs.simulation_4.0.1.v20160914-0420.jar $DEST/
#cp /home/data/httpd/download.eclipse.org/stardust/milestones/neon/4.0.1/plugins/org.eclipse.stardust.docs.spring_4.0.1.v20160914-0420.jar $DEST/
#cp /home/data/httpd/download.eclipse.org/stardust/milestones/neon/4.0.1/plugins/org.eclipse.stardust.docs.wst_4.0.1.v20160914-0420.jar $DEST/

#papyrus

cp /home/data/httpd/download.eclipse.org/modeling/mdt/papyrus/updates/releases/neon/2.0.0/main/plugins/org.eclipse.papyrus.cdo.ui.doc_1.2.0.201606080854.jar $DEST/
cp /home/data/httpd/download.eclipse.org/modeling/mdt/papyrus/updates/releases/neon/2.0.0/main/plugins/org.eclipse.papyrus.copypaste.ui.doc_1.2.0.201606080854.jar $DEST/
cp /home/data/httpd/download.eclipse.org/modeling/mdt/papyrus/updates/releases/neon/2.0.0/main/plugins/org.eclipse.papyrus.dsml.validation.doc_1.2.0.201606080854.jar $DEST/
cp /home/data/httpd/download.eclipse.org/modeling/mdt/papyrus/updates/releases/neon/2.0.0/main/plugins/org.eclipse.papyrus.emf.facet.aggregate.doc_1.2.0.201606080854.jar $DEST/
cp /home/data/httpd/download.eclipse.org/modeling/mdt/papyrus/updates/releases/neon/2.0.0/main/plugins/org.eclipse.papyrus.emf.facet.custom.doc_1.2.0.201606080854.jar $DEST/
cp /home/data/httpd/download.eclipse.org/modeling/mdt/papyrus/updates/releases/neon/2.0.0/main/plugins/org.eclipse.papyrus.emf.facet.custom.metamodel.editor.doc_1.2.0.201606080854.jar $DEST/
cp /home/data/httpd/download.eclipse.org/modeling/mdt/papyrus/updates/releases/neon/2.0.0/main/plugins/org.eclipse.papyrus.emf.facet.doc_1.2.0.201606080854.jar $DEST/
cp /home/data/httpd/download.eclipse.org/modeling/mdt/papyrus/updates/releases/neon/2.0.0/main/plugins/org.eclipse.papyrus.emf.facet.efacet.doc_1.2.0.201606080854.jar $DEST/
cp /home/data/httpd/download.eclipse.org/modeling/mdt/papyrus/updates/releases/neon/2.0.0/main/plugins/org.eclipse.papyrus.emf.facet.util.emf.doc_1.2.0.201606080854.jar $DEST/
cp /home/data/httpd/download.eclipse.org/modeling/mdt/papyrus/updates/releases/neon/2.0.0/main/plugins/org.eclipse.papyrus.infra.doc_1.2.0.201606080854.jar $DEST/
cp /home/data/httpd/download.eclipse.org/modeling/mdt/papyrus/updates/releases/neon/2.0.0/main/plugins/org.eclipse.papyrus.infra.gmfdiag.common.doc_1.2.0.201606080854.jar $DEST/
cp /home/data/httpd/download.eclipse.org/modeling/mdt/papyrus/updates/releases/neon/2.0.0/main/plugins/org.eclipse.papyrus.infra.gmfdiag.css.doc_1.2.0.201606080854.jar $DEST/
cp /home/data/httpd/download.eclipse.org/modeling/mdt/papyrus/updates/releases/neon/2.0.0/main/plugins/org.eclipse.papyrus.infra.nattable.doc_1.2.0.201606080854.jar $DEST/
cp /home/data/httpd/download.eclipse.org/modeling/mdt/papyrus/updates/releases/neon/2.0.0/main/plugins/org.eclipse.papyrus.infra.newchild.doc_1.2.0.201606080854.jar $DEST/
cp /home/data/httpd/download.eclipse.org/modeling/mdt/papyrus/updates/releases/neon/2.0.0/main/plugins/org.eclipse.papyrus.infra.services.controlmode.doc_1.2.0.201606080854.jar $DEST/
cp /home/data/httpd/download.eclipse.org/modeling/mdt/papyrus/updates/releases/neon/2.0.0/main/plugins/org.eclipse.papyrus.infra.types.doc_2.0.0.201606080854.jar $DEST/
cp /home/data/httpd/download.eclipse.org/modeling/mdt/papyrus/updates/releases/neon/2.0.0/main/plugins/org.eclipse.papyrus.infra.viewpoints.doc_1.2.0.201606080854.jar $DEST/
cp /home/data/httpd/download.eclipse.org/modeling/mdt/papyrus/updates/releases/neon/2.0.0/main/plugins/org.eclipse.papyrus.layers.documentation_1.2.0.201606080854.jar $DEST/
cp /home/data/httpd/download.eclipse.org/modeling/mdt/papyrus/updates/releases/neon/2.0.0/main/plugins/org.eclipse.papyrus.req.reqif.doc_1.2.0.201606080854.jar $DEST/
cp /home/data/httpd/download.eclipse.org/modeling/mdt/papyrus/updates/releases/neon/2.0.0/main/plugins/org.eclipse.papyrus.uml.decoratormodel.doc_1.2.0.201606080854.jar $DEST/
cp /home/data/httpd/download.eclipse.org/modeling/mdt/papyrus/updates/releases/neon/2.0.0/main/plugins/org.eclipse.papyrus.uml.diagram.common.doc_1.2.0.201606080854.jar $DEST/
cp /home/data/httpd/download.eclipse.org/modeling/mdt/papyrus/updates/releases/neon/2.0.0/main/plugins/org.eclipse.papyrus.uml.diagram.profile.doc_1.2.0.201606080854.jar $DEST/
cp /home/data/httpd/download.eclipse.org/modeling/mdt/papyrus/updates/releases/neon/2.0.0/main/plugins/org.eclipse.papyrus.uml.doc_1.2.0.201606080854.jar $DEST/
cp /home/data/httpd/download.eclipse.org/modeling/mdt/papyrus/updates/releases/neon/2.0.0/main/plugins/org.eclipse.papyrus.uml.documentation.profile_1.2.0.201606080854.jar $DEST/
cp /home/data/httpd/download.eclipse.org/modeling/mdt/papyrus/updates/releases/neon/2.0.0/main/plugins/org.eclipse.papyrus.uml.modelrepair.doc_1.2.0.201606080854.jar $DEST/
cp /home/data/httpd/download.eclipse.org/modeling/mdt/papyrus/updates/releases/neon/2.0.0/main/plugins/org.eclipse.papyrus.uml.profile.assistants.doc_1.2.0.201606080854.jar $DEST/
cp /home/data/httpd/download.eclipse.org/modeling/mdt/papyrus/updates/releases/neon/2.0.0/main/plugins/org.eclipse.papyrus.uml.search.ui.doc_1.2.0.201606080854.jar $DEST/
cp /home/data/httpd/download.eclipse.org/modeling/mdt/papyrus/updates/releases/neon/2.0.0/main/plugins/org.eclipse.papyrus.views.properties.doc_1.2.0.201606080854.jar $DEST/
cp /home/data/httpd/download.eclipse.org/modeling/mdt/papyrus/updates/releases/neon/2.0.0/main/plugins/org.eclipse.papyrus.views.references.doc_1.2.0.201606080854.jar $DEST/
cp /home/data/httpd/download.eclipse.org/modeling/mdt/papyrus/updates/releases/neon/2.0.1/main/plugins/org.eclipse.papyrus.uml.documentation.profile_1.2.0.201609141603.jar $DEST/
cp /home/data/httpd/download.eclipse.org/modeling/mdt/papyrus/updates/releases/neon/2.0.1/main/plugins/org.eclipse.papyrus.infra.services.controlmode.doc_1.2.0.201609141603.jar $DEST/

#tracecompass

cp /home/data/httpd/download.eclipse.org/tracecompass/neon/milestones/ur1-rc4/plugins/org.eclipse.tracecompass.doc.dev_2.1.0.201609141510.jar $DEST/
cp /home/data/httpd/download.eclipse.org/tracecompass/neon/milestones/ur1-rc4/plugins/org.eclipse.tracecompass.doc.user_2.1.0.201609141510.jar $DEST/
cp /home/data/httpd/download.eclipse.org/tracecompass/neon/milestones/ur1-rc4/plugins/org.eclipse.tracecompass.tmf.pcap.doc.user_2.1.0.201609141510.jar $DEST/
cp /home/data/httpd/download.eclipse.org/tracecompass/neon/milestones/ur1-rc4/plugins/org.eclipse.tracecompass.gdbtrace.doc.user_2.1.0.201609141510.jar $DEST/

#RAP

cp /home/data/httpd/download.eclipse.org/rt/rap/tools/3.1/RC4-20160608-0734/plugins/org.eclipse.rap.doc_3.1.0.20160530-1323.jar $DEST/

#OCL

cp /home/data/httpd/download.eclipse.org/modeling/mdt/ocl/updates/releases/6.1.0/plugins/org.eclipse.ocl.doc_3.6.0.v20160523-1150.jar $DEST/

#QVTd

cp /home/data/httpd/download.eclipse.org/mmt/qvtd/updates/releases/0.13.0/plugins/org.eclipse.qvtd.doc_0.13.0.v20160607-1505.jar $DEST/

#QVTo

cp /home/data/httpd/download.eclipse.org/mmt/qvto/updates/releases/3.6.0/plugins/org.eclipse.m2m.qvt.oml.doc_3.6.0.v20160606-1156.jar $DEST/
cp /home/data/httpd/download.eclipse.org/mmt/qvto/updates/releases/3.6.0/plugins/org.eclipse.m2m.qvt.oml.tools.coverage.doc_1.2.0.v20160606-1156.jar $DEST/

#cdt

cp /home/data/httpd/download.eclipse.org/tools/cdt/builds/neon/milestones/rc4/plugins/org.eclipse.cdt.autotools.docs_2.0.2.201606062011.jar $DEST/
cp /home/data/httpd/download.eclipse.org/tools/cdt/builds/neon/milestones/rc4/plugins/org.eclipse.cdt.debug.application.doc_1.1.0.201606062011.jar $DEST/
cp /home/data/httpd/download.eclipse.org/tools/cdt/builds/neon/milestones/rc4/plugins/org.eclipse.cdt.doc.isv_5.4.0.201606062011.jar $DEST/
cp /home/data/httpd/download.eclipse.org/tools/cdt/builds/neon/milestones/rc4/plugins/org.eclipse.cdt.doc.user_5.4.0.201606062011.jar $DEST/

cp /home/data/httpd/download.eclipse.org/modeling/emf/cdo/drops/R20160607-1209/plugins/org.eclipse.emf.cdo.doc_4.1.400.v20160607-1511.jar $DEST/
cp /home/data/httpd/download.eclipse.org/modeling/emf/cdo/drops/R20160607-1209/plugins/org.eclipse.net4j.db.doc_4.1.400.v20160607-1511.jar $DEST/
cp /home/data/httpd/download.eclipse.org/modeling/emf/cdo/drops/R20160607-1209/plugins/org.eclipse.net4j.doc_4.1.400.v20160607-1511.jar $DEST/
cp /home/data/httpd/download.eclipse.org/modeling/emf/cdo/drops/R20160607-1209/plugins/org.eclipse.net4j.util.doc_4.1.400.v20160607-1511.jar $DEST/

#oomph

cp /home/data/httpd/download.eclipse.org/oomph/drops/release/1.5.0/plugins/org.eclipse.oomph.p2.doc_1.5.0.v20160707-0243.jar $DEST/
cp /home/data/httpd/download.eclipse.org/oomph/drops/release/1.5.0/plugins/org.eclipse.oomph.setup.doc_1.5.0.v20160707-0243.jar $DEST/
cp /home/data/httpd/download.eclipse.org/oomph/drops/release/1.5.0/plugins/org.eclipse.oomph.targlets.doc_1.5.0.v20160706-1144.jar $DEST/
cp /home/data/httpd/download.eclipse.org/oomph/drops/release/1.5.0/plugins/org.eclipse.oomph.util.doc_1.5.0.v20160707-0243.jar $DEST/

#object teams

#cp /home/data/users/sherrmann/downloads/objectteams/updates/ot2.5-milestones/201606070956/plugins/org.eclipse.objectteams.otdt.doc_2.5.0.201606070956.jar $DEST/

#eef

cp /home/data/httpd/download.eclipse.org/modeling/emft/eef/updates/releases/1.6/R20160525090447/plugins/org.eclipse.eef.documentation_1.6.0.201605251308.jar $DEST/

#graphiti

cp /home/data/httpd/download.eclipse.org/graphiti/doc/0.13.0/org.eclipse.graphiti.doc_0.13.0.v20160608-1043.jar $DEST/

#UML2

cp /home/data/httpd/download.eclipse.org/modeling/mdt/uml2/updates/5.2/R201605160939/plugins/org.eclipse.uml2.doc_5.0.0.v20160516-0939.jar $DEST/


#wtp

cp /home/data/httpd/download.eclipse.org/webtools/downloads/drops/R3.8.0/R-3.8.0-20160608130753/repository/plugins/org.eclipse.jpt.doc.isv_3.4.0.v201309202144.jar $DEST/
cp /home/data/httpd/download.eclipse.org/webtools/downloads/drops/R3.8.0/R-3.8.0-20160608130753/repository/plugins/org.eclipse.jpt.doc.user_3.2.100.v201308231650.jar $DEST/
cp /home/data/httpd/download.eclipse.org/webtools/downloads/drops/R3.8.0/R-3.8.0-20160608130753/repository/plugins/org.eclipse.jpt.jpadiagrameditor.doc.user_1.2.101.v201501141513.jar $DEST/
cp /home/data/httpd/download.eclipse.org/webtools/downloads/drops/R3.8.0/R-3.8.0-20160608130753/repository/plugins/org.eclipse.jst.ejb.doc.user_1.1.301.v201105130955.jar $DEST/
cp /home/data/httpd/download.eclipse.org/webtools/downloads/drops/R3.8.0/R-3.8.0-20160608130753/repository/plugins/org.eclipse.jst.j2ee.doc.user_1.1.400.v201008122207.jar $DEST/
cp /home/data/httpd/download.eclipse.org/webtools/downloads/drops/R3.8.0/R-3.8.0-20160608130753/repository/plugins/org.eclipse.jst.jsf.doc.dev_1.5.0.v201309172352.jar $DEST/
cp /home/data/httpd/download.eclipse.org/webtools/downloads/drops/R3.8.0/R-3.8.0-20160608130753/repository/plugins/org.eclipse.jst.jsf.doc.user_1.5.0.v201309172352.jar $DEST/
cp /home/data/httpd/download.eclipse.org/webtools/downloads/drops/R3.8.0/R-3.8.0-20160608130753/repository/plugins/org.eclipse.jst.server.ui.doc.user_1.0.600.v201309182117.jar $DEST/
cp /home/data/httpd/download.eclipse.org/webtools/downloads/drops/R3.8.0/R-3.8.0-20160608130753/repository/plugins/org.eclipse.jst.ws.axis2.ui.doc.user_1.0.200.v201309242118.jar $DEST/
cp /home/data/httpd/download.eclipse.org/webtools/downloads/drops/R3.8.0/R-3.8.0-20160608130753/repository/plugins/org.eclipse.jst.ws.axis.ui.doc.user_1.1.200.v201309242123.jar $DEST/
cp /home/data/httpd/download.eclipse.org/webtools/downloads/drops/R3.8.0/R-3.8.0-20160608130753/repository/plugins/org.eclipse.jst.ws.consumption.ui.doc.user_1.0.700.v201309242123.jar $DEST/
cp /home/data/httpd/download.eclipse.org/webtools/downloads/drops/R3.8.0/R-3.8.0-20160608130753/repository/plugins/org.eclipse.jst.ws.cxf.doc.user_1.0.300.v201309232209.jar $DEST/
cp /home/data/httpd/download.eclipse.org/webtools/downloads/drops/R3.8.0/R-3.8.0-20160608130753/repository/plugins/org.eclipse.jst.ws.doc.user_1.0.700.v201309242123.jar $DEST/
cp /home/data/httpd/download.eclipse.org/webtools/downloads/drops/R3.8.0/R-3.8.0-20160608130753/repository/plugins/org.eclipse.jst.ws.jaxws.doc.isv_1.1.200.v201309232152.jar $DEST/
cp /home/data/httpd/download.eclipse.org/webtools/downloads/drops/R3.8.0/R-3.8.0-20160608130753/repository/plugins/org.eclipse.jst.ws.jaxws.doc.user_1.0.400.v201309232209.jar $DEST/
cp /home/data/httpd/download.eclipse.org/webtools/downloads/drops/R3.8.0/R-3.8.0-20160608130753/repository/plugins/org.eclipse.jst.ws.jaxws.dom.doc.isv_1.0.100.v201309232152.jar $DEST/
cp /home/data/httpd/download.eclipse.org/webtools/downloads/drops/R3.8.0/R-3.8.0-20160608130753/repository/plugins/org.eclipse.servertools.doc.isv_1.0.200.v201309182117.jar $DEST/
cp /home/data/httpd/download.eclipse.org/webtools/downloads/drops/R3.8.0/R-3.8.0-20160608130753/repository/plugins/org.eclipse.wst.command.env.doc.user_1.5.400.v201309242123.jar $DEST/
cp /home/data/httpd/download.eclipse.org/webtools/downloads/drops/R3.8.0/R-3.8.0-20160608130753/repository/plugins/org.eclipse.wst.common.api.doc_1.0.1.v200807181719.jar $DEST/
cp /home/data/httpd/download.eclipse.org/webtools/downloads/drops/R3.8.0/R-3.8.0-20160608130753/repository/plugins/org.eclipse.wst.common.project.facet.doc.api_1.4.400.v201309241214.jar $DEST/
cp /home/data/httpd/download.eclipse.org/webtools/downloads/drops/R3.8.0/R-3.8.0-20160608130753/repository/plugins/org.eclipse.wst.doc.user_1.2.0.v201309112106.jar $DEST/
cp /home/data/httpd/download.eclipse.org/webtools/downloads/drops/R3.8.0/R-3.8.0-20160608130753/repository/plugins/org.eclipse.wst.dtdeditor.doc.user_1.0.700.v201208081537.jar $DEST/
cp /home/data/httpd/download.eclipse.org/webtools/downloads/drops/R3.8.0/R-3.8.0-20160608130753/repository/plugins/org.eclipse.wst.jsdt.doc_1.4.101.v201507140011.jar $DEST/
cp /home/data/httpd/download.eclipse.org/webtools/downloads/drops/R3.8.0/R-3.8.0-20160608130753/repository/plugins/org.eclipse.wst.server.ui.doc.user_1.1.600.v201309182117.jar $DEST/
cp /home/data/httpd/download.eclipse.org/webtools/downloads/drops/R3.8.0/R-3.8.0-20160608130753/repository/plugins/org.eclipse.wst.sse.doc.user_1.1.100.v201208081537.jar $DEST/
cp /home/data/httpd/download.eclipse.org/webtools/downloads/drops/R3.8.0/R-3.8.0-20160608130753/repository/plugins/org.eclipse.wst.validation.doc.isv_1.2.300.v201209262011.jar $DEST/
cp /home/data/httpd/download.eclipse.org/webtools/downloads/drops/R3.8.0/R-3.8.0-20160608130753/repository/plugins/org.eclipse.wst.webtools.doc.user_1.0.500.v201208081537.jar $DEST/
cp /home/data/httpd/download.eclipse.org/webtools/downloads/drops/R3.8.0/R-3.8.0-20160608130753/repository/plugins/org.eclipse.wst.ws.api.doc_1.0.100.v201309242123.jar $DEST/
cp /home/data/httpd/download.eclipse.org/webtools/downloads/drops/R3.8.0/R-3.8.0-20160608130753/repository/plugins/org.eclipse.wst.wsdl.doc.isv_1.0.300.v201309242123.jar $DEST/
cp /home/data/httpd/download.eclipse.org/webtools/downloads/drops/R3.8.0/R-3.8.0-20160608130753/repository/plugins/org.eclipse.wst.wsdl.ui.doc.user_1.0.850.v201309242123.jar $DEST/
cp /home/data/httpd/download.eclipse.org/webtools/downloads/drops/R3.8.0/R-3.8.0-20160608130753/repository/plugins/org.eclipse.wst.wsi.ui.doc.user_1.0.750.v201309242123.jar $DEST/
cp /home/data/httpd/download.eclipse.org/webtools/downloads/drops/R3.8.0/R-3.8.0-20160608130753/repository/plugins/org.eclipse.wst.xmleditor.doc.user_1.0.700.v201208081537.jar $DEST/
cp /home/data/httpd/download.eclipse.org/webtools/downloads/drops/R3.8.0/R-3.8.0-20160608130753/repository/plugins/org.eclipse.wst.xml.xpath2.processor.doc.user_2.0.0.v201209212251.jar $DEST/
cp /home/data/httpd/download.eclipse.org/webtools/downloads/drops/R3.8.0/R-3.8.0-20160608130753/repository/plugins/org.eclipse.wst.xsdeditor.doc.user_1.0.800.v201208081537.jar $DEST/
cp /home/data/httpd/download.eclipse.org/webtools/downloads/drops/R3.8.0/R-3.8.0-20160608130753/repository/plugins/org.eclipse.wst.xsl.doc_1.0.100.v201309251559.jar $DEST/
cp /home/data/httpd/download.eclipse.org/webtools/downloads/drops/R3.8.0/R-3.8.0-20160608130753/repository/plugins/org.eclipse.wst.xsl.sdk.documentation_1.0.100.v201208081544.jar $DEST/

#facet

cp /home/data/httpd/download.eclipse.org/facet/updates/release/1.1.0/plugins/org.eclipse.emf.facet.aggregate.doc_1.1.0.201603181016.jar $DEST/
cp /home/data/httpd/download.eclipse.org/facet/updates/release/1.1.0/plugins/org.eclipse.emf.facet.custom.doc_1.1.0.201603181016.jar $DEST/
cp /home/data/httpd/download.eclipse.org/facet/updates/release/1.1.0/plugins/org.eclipse.emf.facet.doc_1.1.0.201603181016.jar $DEST/
cp /home/data/httpd/download.eclipse.org/facet/updates/release/1.1.0/plugins/org.eclipse.emf.facet.doc.api.report_1.1.0.201603181016.jar $DEST/
cp /home/data/httpd/download.eclipse.org/facet/updates/release/1.1.0/plugins/org.eclipse.emf.facet.doc.metric.report_1.1.0.201603181016.jar $DEST/
cp /home/data/httpd/download.eclipse.org/facet/updates/release/1.1.0/plugins/org.eclipse.emf.facet.doc.test.report_1.1.0.201603181016.jar $DEST/
cp /home/data/httpd/download.eclipse.org/facet/updates/release/1.1.0/plugins/org.eclipse.emf.facet.efacet.doc_1.1.0.201603181016.jar $DEST/
cp /home/data/httpd/download.eclipse.org/facet/updates/release/1.1.0/plugins/org.eclipse.emf.facet.util.emf.doc_1.1.0.201603181016.jar $DEST/
cp /home/data/httpd/download.eclipse.org/facet/updates/release/1.1.0/plugins/org.eclipse.emf.facet.widgets.table.doc_1.1.0.201603181016.jar $DEST/

#modisco

cp /home/data/httpd/download.eclipse.org/modeling/mdt/modisco/updates/release/1.0.0/plugins/org.eclipse.modisco.doc_1.0.0.201605180829.jar $DEST/
cp /home/data/httpd/download.eclipse.org/modeling/mdt/modisco/updates/release/1.0.0/plugins/org.eclipse.modisco.doc.api.report_1.0.0.201605180829.jar $DEST/
cp /home/data/httpd/download.eclipse.org/modeling/mdt/modisco/updates/release/1.0.0/plugins/org.eclipse.modisco.doc.metric.report_1.0.0.201605180829.jar $DEST/
cp /home/data/httpd/download.eclipse.org/modeling/mdt/modisco/updates/release/1.0.0/plugins/org.eclipse.modisco.doc.test.report_1.0.0.201605180829.jar $DEST/
cp /home/data/httpd/download.eclipse.org/modeling/mdt/modisco/updates/release/1.0.0/plugins/org.eclipse.modisco.infra.omg.doc_1.0.0.201605180829.jar $DEST/
cp /home/data/httpd/download.eclipse.org/modeling/mdt/modisco/updates/release/1.0.0/plugins/org.eclipse.modisco.infrastructure.doc_1.0.0.201605180829.jar $DEST/
cp /home/data/httpd/download.eclipse.org/modeling/mdt/modisco/updates/release/1.0.0/plugins/org.eclipse.modisco.java.doc_1.0.0.201605180829.jar $DEST/
cp /home/data/httpd/download.eclipse.org/modeling/mdt/modisco/updates/release/1.0.0/plugins/org.eclipse.modisco.jee.doc_1.0.0.201605180829.jar $DEST/
cp /home/data/httpd/download.eclipse.org/modeling/mdt/modisco/updates/release/1.0.0/plugins/org.eclipse.modisco.usecase.modelfilter.doc_1.0.0.201605180829.jar $DEST/
cp /home/data/httpd/download.eclipse.org/modeling/mdt/modisco/updates/release/1.0.0/plugins/org.eclipse.modisco.usecase.simpletransformationchain.doc_1.0.0.201605180829.jar $DEST/
cp /home/data/httpd/download.eclipse.org/modeling/mdt/modisco/updates/release/1.0.0/plugins/org.eclipse.modisco.xml.doc_1.0.0.201605180829.jar $DEST/

#linuxtools

cp /home/data/httpd/download.eclipse.org/linuxtools/update-neon-1-rc4a/plugins/org.eclipse.linuxtools.callgraph.docs_1.0.0.201609141916.jar $DEST/
cp /home/data/httpd/download.eclipse.org/linuxtools/update-neon-1-rc4a/plugins/org.eclipse.linuxtools.cdt.libhover.library.docs_1.0.2.201609141916.jar $DEST/
cp /home/data/httpd/download.eclipse.org/linuxtools/update-neon-1-rc4a/plugins/org.eclipse.linuxtools.changelog.doc_2.7.1.201609141916.jar $DEST/
cp /home/data/httpd/download.eclipse.org/linuxtools/update-neon-1-rc4a/plugins/org.eclipse.linuxtools.gcov.docs_1.0.0.201609141916.jar $DEST/
cp /home/data/httpd/download.eclipse.org/linuxtools/update-neon-1-rc4a/plugins/org.eclipse.linuxtools.gprof.docs_1.0.0.201609141916.jar $DEST/
cp /home/data/httpd/download.eclipse.org/linuxtools/update-neon-1-rc4a/plugins/org.eclipse.linuxtools.javadocs_1.0.0.201609141916.jar $DEST/
cp /home/data/httpd/download.eclipse.org/linuxtools/update-neon-1-rc4a/plugins/org.eclipse.linuxtools.javadocs.source_1.0.0.201609141916.jar $DEST/
cp /home/data/httpd/download.eclipse.org/linuxtools/update-neon-1-rc4a/plugins/org.eclipse.linuxtools.oprofile.doc_1.0.0.201609141916.jar $DEST/
cp /home/data/httpd/download.eclipse.org/linuxtools/update-neon-1-rc4a/plugins/org.eclipse.linuxtools.perf.doc_1.0.0.201609141916.jar $DEST/
cp /home/data/httpd/download.eclipse.org/linuxtools/update-neon-1-rc4a/plugins/org.eclipse.linuxtools.profiling.docs_1.0.0.201609141916.jar $DEST/
cp /home/data/httpd/download.eclipse.org/linuxtools/update-neon-1-rc4a/plugins/org.eclipse.linuxtools.rpm.ui.editor.doc_1.0.0.201609141916.jar $DEST/
cp /home/data/httpd/download.eclipse.org/linuxtools/update-neon-1-rc4a/plugins/org.eclipse.linuxtools.systemtap.ui.doc_2.6.5.201609141916.jar $DEST/
cp /home/data/httpd/download.eclipse.org/linuxtools/update-neon-1-rc4a/plugins/org.eclipse.linuxtools.valgrind.doc_1.0.0.201609141916.jar $DEST/

cp /home/data/httpd/download.eclipse.org/linuxtools/update-neon-1-docker-rc4a/plugins/org.eclipse.linuxtools.docker.docs_2.1.0.201609141916.jar $DEST/
cp /home/data/httpd/download.eclipse.org/linuxtools/update-neon-1-docker-rc4a/plugins/org.eclipse.linuxtools.vagrant.docs_2.0.0.201609141916.jar $DEST/

#mat

cp /home/data/httpd/download.eclipse.org/mat/neon/RC3/update-site/plugins/org.eclipse.mat.ui.help_1.6.0.201605311117.jar $DEST/

#ecore

cp /home/data/httpd/download.eclipse.org/ecoretools/updates/milestones/3.1.0RC3/neon/plugins/org.eclipse.emf.ecoretools.doc_3.1.0.201605311155.jar $DEST/

#mylyn

cp /home/data/httpd/download.eclipse.org/mylyn/drops/3.20.0/v20160608-1917/plugins/org.eclipse.mylyn.docs.epub.help_2.1.0.v20160429-2231.jar $DEST/
cp /home/data/httpd/download.eclipse.org/mylyn/drops/3.20.0/v20160608-1917/plugins/org.eclipse.mylyn.wikitext.help.ui_2.9.0.v20160524-0547.jar $DEST/
cp /home/data/httpd/download.eclipse.org/mylyn/drops/3.20.0/v20160608-1917/plugins/org.eclipse.mylyn.wikitext.help.sdk_2.9.0.v20160513-1433.jar $DEST/
cp /home/data/httpd/download.eclipse.org/mylyn/drops/3.20.0/v20160608-1917/plugins/org.eclipse.mylyn.help.ui_3.20.0.v20160425-1835.jar $DEST/

#emfcompare & acceleo

#cp /home/data/httpd/download.eclipse.org/staging/neon/plugins/org.eclipse.acceleo.doc_3.6.5.201608301456.jar $DEST/
#cp /home/data/httpd/download.eclipse.org/staging/neon/plugins/org.eclipse.acceleo.query.doc_5.0.1.201608301456.jar $DEST/
#cp /home/data/httpd/download.eclipse.org/staging/neon/plugins/org.eclipse.emf.compare.doc_3.2.0.201608311750.jar $DEST/

#misc emf subs

cp /home/data/httpd/download.eclipse.org/staging/neon/plugins/org.eclipse.emf.doc_2.9.0.v20160526-0356.jar $DEST/
#cp /home/data/httpd/download.eclipse.org/staging/neon/plugins/org.eclipse.emf.ecoretools.doc_3.1.0.201605311155.jar $DEST/
cp /home/data/httpd/download.eclipse.org/staging/neon/plugins/org.eclipse.emf.eef.doc_1.5.1.201601141612.jar $DEST/
cp /home/data/httpd/download.eclipse.org/staging/neon/plugins/org.eclipse.emf.query.doc_1.2.0.201606071631.jar $DEST/
cp /home/data/httpd/download.eclipse.org/staging/neon/plugins/org.eclipse.emf.transaction.doc_1.4.0.201606071900.jar $DEST/
cp /home/data/httpd/download.eclipse.org/staging/neon/plugins/org.eclipse.emf.validation.doc_1.3.0.201606071713.jar $DEST/
cp /home/data/httpd/download.eclipse.org/staging/neon/plugins/org.eclipse.emf.workspace.doc_1.3.0.201606071900.jar $DEST/
cp /home/data/httpd/download.eclipse.org/staging/neon/plugins/org.eclipse.m2m.atl.doc_3.6.0.v201505180909.jar $DEST/

#remote

cp /home/data/httpd/download.eclipse.org/releases/neon/201606221000/plugins/org.eclipse.remote.doc.isv_1.0.0.201605242106.jar $DEST/

#jubula

cp /home/data/httpd/download.eclipse.org/jubula/release/neon/plugins/org.eclipse.jubula.client.ua.help_4.0.0.201605250813.jar $DEST/

#ptp

#cp /home/data/httpd/download.eclipse.org/tools/ptp/builds/nightly/plugins/org.eclipse.photran.doc.user_9.0.0.201611100303.jar $DEST/
#cp /home/data/httpd/download.eclipse.org/tools/ptp/builds/nightly/plugins/org.eclipse.ptp.doc.isv_2.0.0.201611181605.jar $DEST/
#cp /home/data/httpd/download.eclipse.org/tools/ptp/builds/nightly/plugins/org.eclipse.ptp.doc.user_9.1.1.201611181605.jar $DEST/
#cp /home/data/httpd/download.eclipse.org/tools/ptp/builds/nightly/plugins/org.eclipse.ptp.etfw.doc.user_1.0.0.201611181605.jar $DEST/
#cp /home/data/httpd/download.eclipse.org/tools/ptp/builds/nightly/plugins/org.eclipse.ptp.etfw.feedback.perfsuite.doc.user_1.0.0.201611181605.jar $DEST/
#cp /home/data/httpd/download.eclipse.org/tools/ptp/builds/nightly/plugins/org.eclipse.ptp.pldt.doc.user_6.0.0.201611181605.jar $DEST/
#cp /home/data/httpd/download.eclipse.org/tools/ptp/builds/nightly/plugins/org.eclipse.ptp.rm.ibm.ll.doc.user_4.0.0.201611181605.jar $DEST/
#cp /home/data/httpd/download.eclipse.org/tools/ptp/builds/nightly/plugins/org.eclipse.ptp.rm.ibm.pe.doc.user_5.0.0.201611181605.jar $DEST/
#cp /home/data/httpd/download.eclipse.org/tools/ptp/builds/nightly/plugins/org.eclipse.ptp.rm.ibm.platform.lsf.doc.user_1.0.0.201611181605.jar $DEST/
#cp /home/data/httpd/download.eclipse.org/tools/ptp/builds/nightly/plugins/org.eclipse.ptp.rm.jaxb.doc.isv_1.0.0.201611181605.jar $DEST/
#cp /home/data/httpd/download.eclipse.org/tools/ptp/builds/nightly/plugins/org.eclipse.ptp.rm.jaxb.doc.user_1.0.0.201611181605.jar $DEST/
