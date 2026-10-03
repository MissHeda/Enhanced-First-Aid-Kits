// Kit registry / lookups
PREP(initKits);
PREP(getKitData);
PREP(getKitName);
PREP(getKitShortName);
PREP(getKitIcon);
PREP(getCapacity);
PREP(getKitContainer);
PREP(getPrototype);
PREP(isKit);
PREP(getCarriedKits);
PREP(holderHasKit);
PREP(findKitHolder);
PREP(getNearbyContainer);
PREP(capacityHint);
PREP(debugContents);

// Kit weight
PREP(getKitLoad);
PREP(getWeightOffset);
PREP(updateVirtualLoad);
PREP(queueVirtualLoad);

// Contents
PREP(getContents);
PREP(hasKits);
PREP(addToUnit);
PREP(getTakeInto);
PREP(isTakeIntoForced);
PREP(setTakeInto);
PREP(isDefaultContents);
PREP(setFollowDefaults);
PREP(setContents);
PREP(getCharges);
PREP(pickCharges);
PREP(adjustCharges);
PREP(reconcileCharges);
PREP(formatCharges);
PREP(getMagazineSize);
PREP(getKitRows);
PREP(getUsedCapacity);
PREP(getItemMass);
PREP(getItemName);
PREP(getItemPicture);
PREP(parseContents);
PREP(normalizeContents);
PREP(getDefaultContents);

// Instance pool
PREP(allocateInstance);
PREP(freeInstance);
PREP(convertKits);
PREP(convertKitsNow);
PREP(dedupeKits);
PREP(requestUnitKits);
PREP(fillCrateKits);
PREP(fillNewInstance);
PREP(parseEditorKits);
PREP(replaceItem);

// Kit contents in loadouts
PREP(getContentsTree);
PREP(getLoadoutKits);
PREP(parseLoadoutKits);
PREP(filterContentsTree);
PREP(restoreContents);
PREP(onLoadoutGet);
PREP(onPreLoadoutSet);
PREP(onLoadoutSet);
PREP(applyLoadoutRestore);
PREP(onArsenalLoadoutVerified);

// Opening kits from the inventory
PREP(openKit);
PREP(initInventoryHooks);
PREP(inventoryDisplayLoad);

// Actions
PREP(applyPreset);
PREP(reopenSettings);
PREP(canPackItem);
PREP(canPackInto);
PREP(countItem);
PREP(formatColumns);
PREP(getArsenalEditing);
PREP(getKitCategory);
PREP(getKitSetting);
PREP(getPackLimit);
PREP(isContentsForced);
PREP(isItemAllowed);
PREP(packItem);
PREP(unpackItem);
PREP(unpackAll);
PREP(removeKit);
PREP(showContents);
PREP(getKitActions);
PREP(addActions);
PREP(settingsChanged);
