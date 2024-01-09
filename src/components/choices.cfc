/**
 * CRUD etc for managing choices
 * @output true
 */
component accessors=true {
    property name="options";
    property name="choices";
    property name="maxChoices";

    optionDataPath = "";
    choiceDataPath = "";

    /**
     * Initialize component
     * @optionDataPath path to the option data json file. Defaults to application setting.
     * @choiceDataPath path to the choice data json file. Defaults to application setting.
     * @maxChoices the max number of choices per week.
     */
    public any function init(
        string optionDataPath = application.optionDataPath, 
        string choiceDataPath = application.choiceDataPath, 
        numeric maxChoices = 3
    ) {
        variables.optionDataPath = arguments.optionDataPath;
        variables.choiceDataPath = arguments.choiceDataPath;

        setOptions(retrieveOptions());
        setChoices(retrieveChoices());
        setMaxChoices(arguments.maxChoices);

        return this;
    }

    /**
     * Get options from file
     * @output false
     */
    public array function retrieveOptions() {
        var options = deserializeJSON(fileRead(optionDataPath));
        return options;
    }

    /**
     * Save choices by day to file
     * @output false
     */
    public void function saveChoices() {
        fileWrite(variables.choiceDataPath, serializeJSON(variables.choices));
    }

    /**
     * Get choices from file
     * @output false
     */
    public array function retrieveChoices() {
        var choices = deserializeJSON(fileRead(variables.choiceDataPath));
        return choices;
    }

    /**
     * Delete choice from file
     * @output false
     * @choiceNumber the number of the choice to remove
     */
    public void function deleteChoice(
        required numeric choiceNumber
    ) {
        arrayDeleteAt(variables.choices, arguments.choiceNumber);
        saveChoices();
    }

    /**
     * Returns a random array of x options 
     * @output false
     * @numChoices number of options to choose, defaults to the limit.
     * @options the options to choose from. Defaults to all options.
     */
    private array function chooseOptions(
        numeric numChoices = getMaxChoices(),
        array options = getOptions()
    ) {
        var chosenOptions = [];

        for (i = 1; i <= arguments.numChoices; i++) {
            var chosenIndex = randRange(1, arrayLen(arguments.options));
            chosenOptions.append(arguments.options[chosenIndex]);
        }

        return chosenOptions;
    }

    /**
     * Remove the items in one array from another array. Returns the updated array minus the removed items.
     * @output false
     * @subjectArray the array we are removing things from
     * @valuesToRemove the values we are removing
     */
    private array function makeArrayUnique(
        required array subjectArray, 
        required array valuesToRemove
    ){
        var resultArray = arguments.subjectArray;

        for (var item in arguments.valuesToRemove) {
            arrayDelete(resultArray, item);
        }

        return resultArray;
    }

    /**
     * Adds new set of choices to the list, made from a combination of new and old choices. Returns the new set of choices.
     * @output true
     * @numNew number of new option choices to use. Defaults to -1, which chooses a random number.
     * @numOld number of old option choices to use. Defaults to -1, which chooses a random number.
     */
    public array function makeChoices(
        numeric numNew = -1, 
        numeric numOld = -1
    ) {
        var newMin = (arguments.numNew) ? 1 : 0;
        var oldMin = (arguments.numOld) ? 1 : 0;

        oldChoiceOptions = getChoices()[arrayLen(getChoices())].choices;
        newChoiceOptions = makeArrayUnique(getOptions(), oldChoiceOptions);

        if (arguments.numNew lt 0 and arguments.numOld lt 0) {
            // Both are random
            newLimit = randRange(newMin, getMaxChoices());
            oldLimit = randRange(oldMin, getMaxChoices() - newLimit);
        }
        else if (arguments.numNew lt 0 and arguments.numOld gte 0) {
            // Just number of new options is random
            oldLimit = arguments.numOld;
            newLimit = randRange(newMin, getMaxChoices() - oldLimit);
        }
        else if (arguments.numOld lt 0 and arguments.numNew gte 0) {
            // Just number of old options is random
            newLimit = arguments.numNew;
            oldLimit = randRange(oldMin, getMaxChoices() - newLimit);
        }
        else {
            // Neither numbers of options are random
            newLimit = arguments.numNew; 
            maxChoicesLeft = getMaxChoices() - newLimit;
            oldLimit = (arguments.numOld > maxChoicesLeft) ? maxChoicesLeft : arguments.numOld;
        }

        newChoices = chooseOptions(newLimit, newChoiceOptions);
        oldChoices = chooseOptions(oldLimit, oldChoiceOptions);
        newChoices.append(oldChoices, true);
        
        // If we didn't get enough random choices, the rest are blank
        if (arrayLen(newChoices) lt getMaxChoices()) {
            for (var i = 1; i lte arrayLen(newChoices) - getMaxChoices(); i++) {
                newChoices.append("");
            }
        }

        variables.choices.append({
            "date" = now(), 
            "choices" = newChoices
        });

        saveChoices();

        return newChoices;
    }
}