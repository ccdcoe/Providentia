// fonts
import { config, dom, library } from "@fortawesome/fontawesome-svg-core";

import {
  faTimes,
  faTimesCircle,
  faPlus,
  faBook,
  faFlask,
  faBox,
  faCogs,
  faCopy,
  faClone,
  faAnglesRight,
  faGears,
  faCloudUploadAlt,
  faAngleLeft,
  faAngleRight,
  faAngleDoubleLeft,
  faAngleDoubleRight,
  faHistory,
  faSearch,
  faIdBadge,
  faKey,
  faLayerGroup,
  faProjectDiagram,
  faNetworkWired,
  faHdd,
  faUsers,
  faServer,
  faDatabase,
  faSlash,
  faEllipsisVertical,
} from "@fortawesome/free-solid-svg-icons";

import { faUbuntu, faWindows } from "@fortawesome/free-brands-svg-icons";

// Make sure this is before any other `fontawesome` API calls
config.autoAddCss = false;

library.add(
  faTimes,
  faTimesCircle,
  faPlus,
  faBook,
  faFlask,
  faBox,
  faCogs,
  faCopy,
  faClone,
  faAnglesRight,
  faGears,
  faCloudUploadAlt,
  faAngleLeft,
  faAngleRight,
  faAngleDoubleLeft,
  faAngleDoubleRight,
  faHistory,
  faSearch,
  faIdBadge,
  faKey,
  faLayerGroup,
  faProjectDiagram,
  faNetworkWired,
  faHdd,
  faUsers,
  faUbuntu,
  faWindows,
  faServer,
  faDatabase,
  faSlash,
  faEllipsisVertical
);

dom.watch();
