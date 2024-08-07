import { useBackend } from '../backend';
import { Button, Divider, LabeledList, NumberInput, RoundGauge, Section, Stack } from '../components';
import { formatPressure } from '../format';
import { Window } from '../layouts';
import { PortableBasicInfo, PortableHoldingTank } from './common/PortableAtmos';
import { ReagentGraph } from './common/ReagentInfo';

const FilterSettings = (props) => {
  const {
    act,
    options,
    current_settings,
  } = props;

  let all_current_settings = options.map((option) => (
    [option, current_settings.find((value) => (value === option.id))]
  ));

  return (
    all_current_settings.map((option, index) => {
      return (
        <Button
          key={index}
          color={option[1] ? "green" : undefined}
          onClick={() => act("toggle-gas", { gasID: option[0].id })}
        >
          {option[0].id}
        </Button>
      );
    })
  );

};

const BasicPressureInfo = (props) => {

  const {
    connected,
    on,
    pressure,
    inletFlow,
    maxPressure,
    minFlow,
    maxFlow,
  } = props

  return (
    <PortableBasicInfo
      connected={connected}
      pressure={pressure}
      maxPressure={maxPressure}
    >
      <LabeledList>
        <LabeledList.Item label="Scrubber Power">
          <Button
            content={on ? 'On' : 'Off'}
            color={on ? 'average' : 'default'}
            onClick={() => act("toggle-power")} />
        </LabeledList.Item>
        <LabeledList.Item label="Inlet Flow">
          <Button
            onClick={() => act("set-inlet-flow", { inletFlow: minFlow })}
            content="Min" />
          <NumberInput
            animated
            width="7em"
            value={inletFlow}
            minValue={minFlow}
            maxValue={maxFlow}
            onChange={(e, newInletFlow) => act("set-inlet-flow", { inletFlow: newInletFlow })} />
          <Button
            onClick={() => act("set-inlet-flow", { inletFlow: maxFlow })}
            content="Max" />
        </LabeledList.Item>
      </LabeledList>
    </PortableBasicInfo>
  );
};

const FourSquareGrid = (props) => {
  const {
    topLeft,
    topRight,
    bottomLeft,
    bottomRight,
    width,
    height,
  } = props;

  return (
    <Stack>
      <Stack.Item>
        <Stack vertical width="3%">
          <Stack.Item>
            {topLeft}
          </Stack.Item>
          <Stack.Item>
            {bottomLeft}
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <Stack vertical width="3%">
          <Stack.Item>
            {topRight}
          </Stack.Item>
          <Stack.Item>
            {bottomRight}
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

export const PortableScrubber = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    connected,
    on,
    holding,
    pressure,
    inletFlow,
    maxPressure,
    minFlow,
    maxFlow,
    reagent_container,
    known_gases,
    blacklist,
  } = data;

  let width=605;
  let height = 600;

  return (
    <Window
      width={width}
      height={height}>
      <Window.Content>
        <FourSquareGrid
          topLeft={
            <BasicPressureInfo
              connected={connected}
              on={on}
              pressure={pressure}
              inletFlow={inletFlow}
              maxPressure={maxPressure}
              minFlow={minFlow}
              maxFlow={maxFlow}
              width={width}
              height={height}
            />
          }
          topRight={
            <PortableHoldingTank
              holding={holding}
              onEjectTank={() => act("eject-tank")}
            />
          }
          bottomLeft={
            <Section title="Fluid Tank">
              <ReagentGraph container={reagent_container} />
            </Section>
          }
          bottomRight={
            <Section title="Filter Settings">
              <FilterSettings act={act} options={known_gases} current_settings={blacklist} />
            </Section>
          }
        />
      </Window.Content>
    </Window>
  );

};
