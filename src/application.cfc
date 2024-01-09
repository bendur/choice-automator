component {

    function onApplicationStart() {
        application.optionDataPath = expandPath("./data/options.json");
        application.choiceDataPath = expandPath("./data/choices.json");
    }
}