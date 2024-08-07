/**
 * @file
 * @copyright 2024
 * @author Romayne (https://github.com/MeggalBozale)
 * @license ISC
 */

import { useBackend, useLocalState } from '../../backend';
import { Box, Button, LabeledList, Section, Stack } from '../../components';
import { COLOR_TERMINAL_BACKGROUND, COLOR_TERMINAL_TEXT } from './constants';
import { is_set } from '../common/bitflag';
import { Window } from '../../layouts';
import { TankInfo } from "../TTV";

const MaintenencePanel = (props:MaintenencePanelProps) => {
  const {
    bits,
    host_id,
    connection,
    act_reset,
    act_flip_bit,
    setConnection,
  } = props;

  let resetButton = <Button icon="wifi" onClick={() => act_reset()}>Reset Connection</Button>;

  if (connection === "NO CONNECTION" && host_id !== null) {
    setConnection("OK CONNECTION");
  }

  return (
    <Section title="Maintenence Panel" buttons={resetButton}>
      <LabeledList.Item label="Host Connection">
        {connection}
      </LabeledList.Item>
      <LabeledList.Item label="Configuration Switches" verticalAlign="middle">
        <Stack>
          <Stack.Item><ConfigSwitch local_bits={bits} handle_click={act_flip_bit} bit_pos={0} /></Stack.Item>
          <Stack.Item><ConfigSwitch local_bits={bits} handle_click={act_flip_bit} bit_pos={1} /></Stack.Item>
          <Stack.Item><ConfigSwitch local_bits={bits} handle_click={act_flip_bit} bit_pos={2} /></Stack.Item>
          <Stack.Item><ConfigSwitch local_bits={bits} handle_click={act_flip_bit} bit_pos={3} /></Stack.Item>
        </Stack>
      </LabeledList.Item>
    </Section>
  );

};

const ConfigSwitch = (props) => {
  const {
    local_bits,
    handle_click,
    bit_pos,
  } = props;
  return (
    <Button width={2} height={2} color={is_set(local_bits, bit_pos) ? "green" : "red"} onClick={() => handle_click(bit_pos)} />
  );
};

const LogMenu = (props:LogMenuProps) => {
  const { log_data, has_tape, screen_height } = props;

  return (
    <Section
      backgroundColor={COLOR_TERMINAL_BACKGROUND}
      color={COLOR_TERMINAL_TEXT}
      fontFamily="Consolas"
      scrollable
      fill
      height={screen_height}
    >
      <Box fill>
        {has_tape ? log_data.map((log_line:string) => {
          return <>{log_line}<br /></>;
        }) : "No log device detected. Please insert tape."}
      </Box>
    </Section>
  );
};

export const Bombsim = (_props, context) => {
  const { act, data } = useBackend<SimulatorData>(context);

  const [bits, setBits] = useLocalState(context, "bits", data.net_number);
  const [connection, setConnection] = useLocalState(context, "connection", "OK CONNECTION");

  let simulationButton = <Button icon="burst" disabled={!data.is_ready} onClick={() => act("simulate")}>Begin Simulation</Button>;
  let screenHeight = (data.panel_open) ? 700 : 550; // 'fill' property doesnt work properly for scrollables

  const act_reset = () => {
    act("reset");
    setConnection("NO CONNECTION");
  };
  const act_flip_bit = (bit_pos:number) => {
    act("config_switch", { "switch_flicked": bit_pos });
    setBits(bits ^ (1 << bit_pos));
  };

  return (
    <Window width={400} height={screenHeight}>
      <Window.Content>
        <Stack vertical>
          <Stack.Item>
            <Stack>
              <Stack.Item>
                <TankInfo tank={data.tank_one} tankNum={1} />
              </Stack.Item>
              <Stack.Item>
                <TankInfo tank={data.tank_two} tankNum={2} />
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item>
            <Section
              mt={1}
              title="Simulator"
              buttons={simulationButton}
            >
              <LabeledList>
                <LabeledList.Item label="Simulation">
                  {(data.vr_bomb !== null) ? "ACTIVE" : "INACTIVE"}
                </LabeledList.Item>
                <LabeledList.Item label="Status">
                  {data.readiness_dialogue}
                </LabeledList.Item>
                <LabeledList.Item label="Cooldown">
                  {(data.is_ready) ? "None" : data.cooldown}
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>
          <Stack.Item>
            {(data.panel_open) ? (
              <MaintenencePanel
                bits={bits}
                host_id={data.host_id}
                connection={connection}
                act_reset={act_reset}
                act_flip_bit={act_flip_bit}
                setConnection={setConnection}
              />) : ""}
          </Stack.Item>
          <Stack.Item>
            <LogMenu log_data={data.log_data} has_tape={data.has_tape} screen_height={screenHeight/30} />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
