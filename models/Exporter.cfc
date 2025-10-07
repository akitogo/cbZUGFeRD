component {
	property name="ze" 				inject="javaloader:org.mustangproject.ZUGFeRD.IZUGFeRDExporter";
    property name="zePdf" 			inject="javaloader:org.mustangproject.ZUGFeRD.ZUGFeRDExporterFromA3";

    function init() {
        return zePdf.init();
    }
}