//------------------------------------------------------------------------------
//  Copyright (c) 2009-2013 the original author or authors. All Rights Reserved.
//
//  NOTICE: You are permitted to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//------------------------------------------------------------------------------

package robotlegs.bender.extensions.directCommandMap.impl
{
	import org.swiftsuspenders.Injector;

	import robotlegs.bender.extensions.commandCenter.api.ICommandExecutor;
	import robotlegs.bender.extensions.commandCenter.impl.CommandExecutor;
	import robotlegs.bender.extensions.commandCenter.impl.CommandMappingList;
	import robotlegs.bender.extensions.commandCenter.impl.CommandPayload;
	import robotlegs.bender.extensions.directCommandMap.api.IDirectCommandMap;
	import robotlegs.bender.extensions.directCommandMap.dsl.IDirectCommandConfigurator;
	import robotlegs.bender.framework.api.IContext;
	import robotlegs.bender.extensions.commandCenter.impl.NullCommandTrigger;

	public class DirectCommandMap implements IDirectCommandMap
	{

		/*============================================================================*/
		/* Private Properties                                                         */
		/*============================================================================*/

		private var _context:IContext;

		private var _executor:ICommandExecutor;

		private var _mappings:CommandMappingList;

		/*============================================================================*/
		/* Constructor                                                                */
		/*============================================================================*/

		/**
		 * @private
		 */
		public function DirectCommandMap(context:IContext)
		{
			_context = context;
			var sandboxedInjector:Injector = context.injector.createChildInjector();
			sandboxedInjector.map(IDirectCommandMap).toValue(this);
			_mappings = new CommandMappingList(new NullCommandTrigger(), context.getLogger(this));
			_executor = new CommandExecutor(sandboxedInjector.createChildInjector(), _mappings.removeMapping);
		}

		/*============================================================================*/
		/* Public Functions                                                           */
		/*============================================================================*/

		/**
		 * @inheritDoc
		 */
		public function map(commandClass:Class):IDirectCommandConfigurator
		{
			return new DirectCommandMapper(_executor, _mappings, commandClass);
		}

		/**
		 * @inheritDoc
		 */
		public function detain(command:Object):void
		{
			_context.detain(command);
		}

		/**
		 * @inheritDoc
		 */
		public function release(command:Object):void
		{
			_context.release(command);
		}

		/**
		 * @inheritDoc
		 */
		public function execute(payload:CommandPayload=null):void
		{
			_executor.executeCommands(_mappings.getList(),payload);
		}

	}
}