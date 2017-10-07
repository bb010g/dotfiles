//META{"name":"Zere's Local Loader"}*//

let ZeresPluginLibraryLoader = class {
    getName() { return "Zere's Local Loader"; }
    getShortName() { return "ZLL"; }
    getDescription() { return "Zere's PluginLibrary and Sortable are already loaded."; }
    getVersion() { return "0.1.0"; }
    getAuthor() { return "bb010g"; }

    constructor() {
        if (typeof window.ZeresLibrary === "undefined" || !$("#zeresLibraryScript").length) {
            const libraryScript = document.createElement("script");
            libraryScript.setAttribute("src", "PluginLibrary.js");
            libraryScript.setAttribute("id", "zeresLibraryScript");
            document.head.appendChild(libraryScript);
        }
    }
};
