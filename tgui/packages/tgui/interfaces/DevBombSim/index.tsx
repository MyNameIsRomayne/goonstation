/**
 * @file
 * @copyright 2024
 * @author Romayne (https://github.com/MyNameIsRomayne)
 * @license ISC
 */

import { useBackend, useLocalState } from '../../backend';
import { Window } from '../../layouts';
import { Tabs } from '../../components';
import { TankBuilder } from './components/TankBuilder';
import { LogOutput } from './components/LogOutput';
import { DevBombSimData } from "./type";

export const DevBombSim = (_, context) => {
  const { act, data } = useBackend<DevBombSimData>(context);
  const [menu, setMenu] = useLocalState(context, "menu", "TankBuilder");

  let currentMenu;
  if (menu === "TankBuilder") {
    currentMenu = <TankBuilder act={act} data={data} />;
  }
  if (menu === "LogOutput") {
    currentMenu = <LogOutput act={act} data={data} />;
  }

  return (
    <Window height={720} width={600}>
      <Window.Content>
        <Tabs>
          <Tabs.Tab
            icon="flask"
            selected={menu === "TankBuilder"}
            onClick={() => setMenu("TankBuilder")}>
            Tank Builder
          </Tabs.Tab>
          <Tabs.Tab
            icon="file-lines"
            selected={menu === "LogOutput"}
            onClick={() => setMenu("LogOutput")}>
            Log Output
          </Tabs.Tab>
        </Tabs>
        {currentMenu}
      </Window.Content>
    </Window>
  );
};
