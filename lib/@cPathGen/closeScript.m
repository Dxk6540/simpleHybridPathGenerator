function ret = closeScript(obj)
    %%% end the script
    obj.openDoor();
    obj.endProgram();
    obj.closeFile();
    ret = 1;
end % closeDoor(obj)