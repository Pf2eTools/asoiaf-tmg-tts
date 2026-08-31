local _identifier = "5cbcbe"
function call(func, params) Global.call("invoke", {class = "ArmyImporter", guid = self.getGUID(), func = func, params = params}) end
function armyInput_onEndEdit(...) call('armyInput_onEndEdit', {...}) end
function chooseColor_onValueChanged(...) call('chooseColor_onValueChanged', {...}) end
function spawnArmy_onClick(...) call('spawnArmy_onClick', {...}) end
function chooseSource_onValueChanged(...) call('chooseSource_onValueChanged', {...}) end