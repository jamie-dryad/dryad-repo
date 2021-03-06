package org.dspace.workflow.actions.processingaction;

import org.dspace.authorize.AuthorizeException;
import org.dspace.content.Item;
import org.dspace.core.Context;
import org.dspace.workflow.Step;
import org.dspace.workflow.WorkflowItem;
import org.dspace.workflow.actions.ActionResult;

import javax.servlet.http.HttpServletRequest;
import java.io.IOException;
import java.sql.SQLException;
import org.apache.log4j.Logger;
import org.dspace.content.DCDate;
import org.dspace.content.MetadataSchema;
import org.dspace.identifier.IdentifierException;
import org.dspace.identifier.IdentifierService;
import org.dspace.utils.DSpace;
import org.dspace.workflow.DryadWorkflowUtils;
import org.dspace.workflow.WorkflowEmailManager;
import org.dspace.workflow.WorkflowManager;

/**
 * This action registers items that are in publication blackout.  
 * It only applies to items in "registerPendingPublicationStep",
 * and on success, items will be placed in "pendingpublicationStep"
 */
public class RegisterPendingPublicationAction extends ProcessingAction{

    private static final int BLACKOUT_REGISTERED = 0;
    private static final Logger log = Logger.getLogger(RegisterPendingPublicationAction.class);

    @Override
    public ActionResult execute(Context c, WorkflowItem wfi, Step step, HttpServletRequest request) throws SQLException, AuthorizeException, IOException {
        return registerItemInBlackout(c, wfi);
    }

    private ActionResult registerItemInBlackout(Context c, WorkflowItem wfi) throws AuthorizeException, SQLException, IOException {
        DSpace dspace = new DSpace();
        IdentifierService service = new DSpace().getSingletonService(IdentifierService.class);
        try {
            service.register(c, wfi.getItem());
            Item[] dataFiles = DryadWorkflowUtils.getDataFiles(c, wfi.getItem());
            for (Item dataFile : dataFiles) {
                service.register(c, dataFile);
            }
            notifyOfBlackout(c, wfi);
        } catch (IdentifierException e) {
            throw new IOException(e);
        }
        return new ActionResult(ActionResult.TYPE.TYPE_OUTCOME, BLACKOUT_REGISTERED);
    }

    private void notifyOfBlackout(Context c, WorkflowItem wfi) {
        try {
            WorkflowEmailManager.notifyOfBlackout(c, wfi.getItem());
        } catch (Exception e) {
            log.error("Problem with notification on send to blackout", e);
        }
    }
}
