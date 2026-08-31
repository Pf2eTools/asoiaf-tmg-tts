local _identifier = "916e27"
function call(func, params) Global.call("invoke", {class = "DiceTray", guid = self.getGUID(), func = func, params = params}) end
function onIncreaseDice_Click(...) call('onIncreaseDice_Click', {...}) end
function onDecreaseDice_Click(...) call('onDecreaseDice_Click', {...}) end
function onDiceCount_ValueChanged(...) call('onDiceCount_ValueChanged', {...}) end
function onIncreaseTarget_Click(...) call('onIncreaseTarget_Click', {...}) end
function onDecreaseTarget_Click(...) call('onDecreaseTarget_Click', {...}) end
function onTargetNumber_ValueChanged(...) call('onTargetNumber_ValueChanged', {...}) end
function onRollDice_Click(...) call('onRollDice_Click', {...}) end
function onRollMisses_Click(...) call('onRollMisses_Click', {...}) end
function onRollHits_Click(...) call('onRollHits_Click', {...}) end
function onDiceTypeDropDown_ValueChanged(...) call('onDiceTypeDropDown_ValueChanged', {...}) end
function onSelectDie_ValueChanged(...) call('onSelectDie_ValueChanged', {...}) end
function onRemovePanicDice_Click(...) call('onRemovePanicDice_Click', {...}) end
function onRollPanicDice_Click(...) call('onRollPanicDice_Click', {...}) end
function onShowPanel_Click(...) call('onShowPanel_Click', {...}) end
function onHidePanel_Click(...) call('onHidePanel_Click', {...}) end