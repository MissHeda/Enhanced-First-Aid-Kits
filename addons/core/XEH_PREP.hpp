// Kit registry / lookups
PREP(initKits);
PREP(getKitData);
PREP(getKitName);
PREP(getKitIcon);
PREP(getCapacity);
PREP(getKitContainer);
PREP(getPrototype);
PREP(isKit);
PREP(getCarriedKits);

// Contents
PREP(getContents);
PREP(setContents);
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
PREP(replaceItem);

// Actions
PREP(canPackItem);
PREP(packItem);
PREP(unpackItem);
PREP(unpackAll);
PREP(startUnpack);
PREP(removeKit);
PREP(showContents);
PREP(getKitActions);
PREP(addActions);
PREP(settingsChanged);
