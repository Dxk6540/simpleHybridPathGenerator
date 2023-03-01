function ret = closeScript(obj)
    %%% end the script
    pg.openDoor();
    pg.endProgram();
    pg.closeFile();
    ret = 1;
end % closeDoor(obj)