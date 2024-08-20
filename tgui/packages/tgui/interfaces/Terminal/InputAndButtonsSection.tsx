/**
 * @file
 * @copyright 2023
 * @author Garash2k (https://github.com/garash2k)
 * @license ISC
 */

import { useState } from 'react';
import { Button, Flex, Section, Tooltip } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { TerminalInput } from './TerminalInput';
import { TerminalData } from './types';

export const InputAndButtonsSection = () => {
  const { act, data } = useBackend<TerminalData>();
  const { TermActive } = data;

  const [localInputValue, setLocalInputValue] = useState(data.inputValue);

  const handleInputEnter = (_e, value) => {
    act('text', { value: value });
  };
  // Tiny bit hacky but needed to force updates on the input box.
  const getDOMInput = () => {
    return document.querySelector(
      ".terminalInput input[class^='_inner']",
    ) as HTMLInputElement;
  };
  const handleEnterClick = () => {
    // Still a tiny bit hacky but it's a manual click on the enter button which already caused me too much grief
    const domInput = getDOMInput();
    act('text', { value: domInput.value });
    domInput.value = '';
  };
  const handleHistoryPrevious = () => act('history', { direction: 'prev' });
  const handleHistoryNext = () => act('history', { direction: 'next' });
  const handleRestartClick = () => act('restart');

  // localInputValue is basically just here to detect changes in passed-in inputValue
  // done this way because forcible updates in handleHistoryPrev/Next are not quick enough
  if (localInputValue !== data.inputValue) {
    getDOMInput().value = data.inputValue;
    setLocalInputValue(data.inputValue);
  }

  return (
    <Section fitted>
      <Flex align="center">
        <Flex.Item grow>
          <TerminalInput
            autoFocus
            value={data.inputValue}
            className="terminalInput"
            placeholder="Type Here"
            selfClear
            fluid
            mr="0.5rem"
            onKeyUp={handleHistoryPrevious}
            onKeyDown={handleHistoryNext}
            onEnter={handleInputEnter}
          />
        </Flex.Item>
        <Flex.Item>
          <Tooltip content="Enter">
            <Button
              icon="share"
              color={TermActive ? 'green' : 'red'}
              onClick={handleEnterClick}
              mr="0.5rem"
              my={0.25}
            />
          </Tooltip>
        </Flex.Item>
        <Flex.Item>
          <Tooltip content="Restart">
            <Button
              icon="repeat"
              color={TermActive ? 'green' : 'red'}
              onClick={handleRestartClick}
              my={0.25}
            />
          </Tooltip>
        </Flex.Item>
      </Flex>
    </Section>
  );
};
