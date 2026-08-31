local _identifier = "d769cd"
function call(func, params) Global.call("invoke", {class = "FactionSpawner", guid = self.getGUID(), func = func, params = params}) end
function onClick_spawnThrottled(...) call('onClick_spawnThrottled', {...}) end
function onClick_clear(...) call('onClick_clear', {...}) end
function onClick_cat(...) call('onClick_cat', {...}) end