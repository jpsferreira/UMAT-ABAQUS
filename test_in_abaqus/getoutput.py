# -*- coding: mbcs -*-
#
# Abaqus/Viewer Release 6.14-3 replay file
# Internal Version: 2015_02_02-21.14.46 134785
# Run by jferreira on Fri Dec 18 14:10:08 2015
#

# from driverUtils import executeOnCaeGraphicsStartup
# executeOnCaeGraphicsStartup()
#: Executing "onCaeGraphicsStartup()" in the site directory ...
from abaqus import *
from abaqusConstants import *
session.Viewport(name='Viewport: 1', origin=(0.0, 0.0), width=243.416656494141, 
    height=165.277770996094)
session.viewports['Viewport: 1'].makeCurrent()
session.viewports['Viewport: 1'].maximize()
from viewerModules import *
from driverUtils import executeOnCaeStartup
executeOnCaeStartup()
o1 = session.openOdb(
    name='/mnt/hgfs/GoogleDrive/abaqus_umat/Hyperelastic/Hyperelastic_cube/cube_umat.odb')
session.viewports['Viewport: 1'].setValues(displayedObject=o1)
#: Model: /mnt/hgfs/GoogleDrive/abaqus_umat/Hyperelastic/Hyperelastic_cube/cube_umat.odb
#: Number of Assemblies:         1
#: Number of Assembly instances: 0
#: Number of Part instances:     1
#: Number of Meshes:             1
#: Number of Element Sets:       3
#: Number of Node Sets:          10
#: Number of Steps:              1
session.viewports['Viewport: 1'].odbDisplay.display.setValues(plotState=(
    CONTOURS_ON_DEF, ))
odb = session.odbs['/mnt/hgfs/GoogleDrive/abaqus_umat/Hyperelastic/Hyperelastic_cube/cube_umat.odb']
session.xyDataListFromField(odb=odb, outputPosition=NODAL, variable=(('U', 
    NODAL, ((COMPONENT, 'U2'), )), ('S', INTEGRATION_POINT, ((INVARIANT, 
    'Max. Principal'), )), ('SDV_DET', INTEGRATION_POINT), ), nodePick=((
    'PART-1-1', 1, ('[#1 ]', )), ), )
xy1 = session.xyDataObjects['U:U2 PI: PART-1-1 N: 1']
xy2 = session.xyDataObjects['S:Max Principal (Avg: 75%) PI: PART-1-1 N: 1']
xy3 = combine(xy1+1, xy2)
xy3.setValues(
    sourceDescription='combine ( "U:U2 PI: PART-1-1 N: 1"+1,"S:Max Principal (Avg: 75%) PI: PART-1-1 N: 1" )')
tmpName = xy3.name
session.xyDataObjects.changeKey(tmpName, 'XYData-1')
x0 = session.xyDataObjects['XYData-1']
session.writeXYReport(fileName='abaqus.rpt', xyData=(x0, ))
x0 = session.xyDataObjects['SDV_DET (Avg: 75%) PI: PART-1-1 N: 1']
session.writeXYReport(fileName='abaqus.rpt', xyData=(x0, ))
