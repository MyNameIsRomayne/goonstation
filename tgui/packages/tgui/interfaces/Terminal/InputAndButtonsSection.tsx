/**
 * @file
 * @copyright 2023
 * @author Garash2k (https://github.com/garash2k)
 * @license ISC
 */

import { useEffect, useState } from 'react';
import { Button, Flex, Section, Tooltip } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { TerminalInput } from './TerminalInput';
import { TerminalData } from './types';

export const InputAndButtonsSection = () => {
  const { act, data } = useBackend<TerminalData>();
  const { TermActive, inputValue, ckey } = data;

  const [localInputValue, setLocalInputValue] = useState(inputValue);

  const handleInputEnter = (_e, value) => {
    act('text', { value: value, ckey: ckey });
    setLocalInputValue('');
  };
  const handleEnterClick = () =>
    act('text', { value: localInputValue, ckey: ckey });
  const handleHistoryPrevious = () =>
    act('history', { direction: 'prev', ckey: ckey });
  const handleHistoryNext = () =>
    act('history', { direction: 'next', ckey: ckey });
  const handleInputChange = (_e, value) => setLocalInputValue(value);
  const handleRestartClick = () => act('restart');

  // When inputValue changes, it means a history event happened, so only then should we erase local input value with what was received from the server.
  useEffect(() => {
    setLocalInputValue(inputValue);
  }, [inputValue]);

  return (
    <Section fitted>
      <Flex align="center">
        <Flex.Item grow>
          <TerminalInput
            autoFocus
            value={localInputValue}
            className="terminalInput"
            placeholder="Type Here"
            selfClear
            fluid
            mr="0.5rem"
            onKeyUp={handleHistoryPrevious}
            onKeyDown={handleHistoryNext}
            onEnter={handleInputEnter}
            onChange={handleInputChange}
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
