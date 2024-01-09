<cfscript>
    param form.action default="";
    param form.deleteChoice default = 0;
    param form.numNew default = 0;
    param form.numOld default = 0;

    choices = new components.choices();
    choiceLimit = choices.getMaxChoices();

    if (form.action eq "chooseNew") {
        choices.makeChoices(form.numNew, form.numOld);
        cflocation(url="index.cfm", addToken=false);
    }

    if (form.action eq "deleteChoice" and form.deleteChoice gt 0) {
        choices.deleteChoice(form.deleteChoice);
        cflocation(url="index.cfm", addToken=false);
    }

    allOptions = choices.getOptions();
    allChoices = choices.getChoices();

    arrayIndex = 1;
</cfscript>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">

        <title>Choice Automator 3000</title>

        <link rel="stylesheet" href="https://unpkg.com/turretcss/dist/turretcss.min.css" crossorigin="anonymous">
        <link rel="stylesheet" href="./styles/main.css">
    </head>
    <body>
        <main class="padding-vertical-xxl">
            <div class="container">
                <h1>Choice Automator 3000</h1>
                <p>
                    Choices are hard, let's have a computer make them for us.
                </p>
                <cfoutput>
                    <p>
                        <strong>Options:</strong> 
                        #arrayToList(allOptions, ", ")# 
                    </p>
                    <p>
                        <form action="index.cfm" method="post">
                            <input type="hidden" name="action" value="chooseNew">
                            <div class="form-row content-block">
                                <div class="form-item">
                                    <label for="numNew" class="select">
                                        ## New Choices
                                        <select name="numNew" id="numNew">
                                            <option value="-1">
                                                Random Number
                                            </option>
                                            <cfloop from="0" to="#choiceLimit#" index="num">
                                                <option value="#num#">
                                                    #num#
                                                </option>
                                            </cfloop>
                                        </select>
                                    </label>
                                </div>
                                <div class="form-item">
                                    <label for="numOld" class="select">
                                        ## Old Choices
                                        <select name="numOld" id="numOld">
                                            <option value="-1">
                                                Random Number
                                            </option>
                                            <cfloop from="0" to="#choiceLimit#" index="num">
                                                <option value="#num#">
                                                    #num#
                                                </option>
                                            </cfloop>
                                        </select>
                                    </label>
                                </div>
                                <div class="form-item">
                                    <button type="submit" class="button button-primary">Choose for me</button>
                                </div>
                            </div>
                        </form>
                    </p>
                    <h2>Choice Log</h2>
                    <table class="table-responsive">
                        <thead>
                            <tr>
                                <th>Date</th>
                                <th>Choice 1</th>
                                <th>Choice 2</th>
                                <th>Choice 3</th>
                                <th class="text-align-right">Delete</th>
                            </tr>
                        </thead>
                        <tbody>
                            <cfloop array="#allChoices#" index="day">
                                <tr>
                                    <td>#dateFormat(day.date, "medium")#</td>
                                    <cfif arrayLen(day.choices)>
                                        <cfloop from="1" to="#choiceLimit#" index="choice">
                                            <cfif arrayLen(day.choices) gte choice>
                                                <td>#day.choices[choice]#</td>
                                            <cfelse>
                                                <td></td>
                                            </cfif>
                                        </cfloop>
                                    <cfelse>
                                        <td></td>
                                        <td></td>
                                        <td></td>
                                    </cfif>
                                    <td class="text-align-right">
                                        <form action="index.cfm" method="post">
                                            <input type="hidden" name="deleteChoice" value="#arrayIndex#">
                                            <input type="hidden" name="action" value="deleteChoice">
                                            <button type="submit" class="button button-xs error button-border">Delete</button>
                                        </form>
                                    </td>
                                </tr>
                                <cfset arrayIndex += 1>
                            </cfloop>
                        </tbody>
                    </table>
                </cfoutput>
            </div>
        </main>
        
    </body>
</html>